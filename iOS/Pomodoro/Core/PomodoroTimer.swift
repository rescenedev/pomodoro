import Foundation
import Combine

/// Drives the Pomodoro countdown and session transitions.
///
/// iOS suspends apps in the background, so the in-app ticker only keeps the UI
/// live in the foreground. Accuracy comes from a wall-clock `deadline`: on
/// returning to foreground `syncRemaining()` recomputes the time left, and a
/// local notification scheduled at the deadline fires the completion alert even
/// while the app is suspended.
@MainActor
final class PomodoroTimer: ObservableObject {
    @Published private(set) var session: SessionType = .focus
    @Published private(set) var remaining: Int
    @Published private(set) var isRunning = false
    /// Number of focus sessions completed in the current long-break cycle.
    @Published private(set) var completedFocusSessions = 0

    private let settings: PomodoroSettings
    private let notifier: NotificationService
    private let haptics: Haptics
    private let liveActivity: LiveActivityController
    private var ticker: AnyCancellable?
    /// Wall-clock deadline; recomputed on every start/resume to avoid timer drift.
    private var deadline: Date?

    init(
        settings: PomodoroSettings,
        notifier: NotificationService,
        haptics: Haptics,
        liveActivity: LiveActivityController
    ) {
        self.settings = settings
        self.notifier = notifier
        self.haptics = haptics
        self.liveActivity = liveActivity
        self.remaining = settings.duration(for: .focus)
    }

    // MARK: - Derived state

    var totalDuration: Int { settings.duration(for: session) }

    var progress: Double {
        let total = totalDuration
        guard total > 0 else { return 0 }
        return Double(total - remaining) / Double(total)
    }

    /// "MM:SS" formatted remaining time.
    var formattedRemaining: String {
        let clamped = max(0, remaining)
        return String(format: "%02d:%02d", clamped / 60, clamped % 60)
    }

    // MARK: - Controls

    func toggle() {
        isRunning ? pause() : start()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        let deadline = Date().addingTimeInterval(TimeInterval(remaining))
        self.deadline = deadline
        scheduleTicker()
        notifier.scheduleSessionEnd(session, at: deadline, playSound: settings.playSound)
        liveActivity.start(session: session, deadline: deadline)
    }

    func pause() {
        guard isRunning else { return }
        syncRemaining()
        isRunning = false
        deadline = nil
        ticker?.cancel()
        ticker = nil
        notifier.cancelScheduled()
        liveActivity.pause(session: session, remaining: remaining)
    }

    /// Reset the current session back to its full duration.
    func reset() {
        pause()
        remaining = settings.duration(for: session)
        liveActivity.end()
    }

    /// Skip to the next session in the cycle without completing the current one.
    func skip() {
        pause()
        advance(countingCurrent: false)
        liveActivity.end()
    }

    /// Manually switch to a specific session type (resets the countdown).
    func select(_ newSession: SessionType) {
        guard newSession != session else { return }
        pause()
        session = newSession
        remaining = settings.duration(for: newSession)
        liveActivity.end()
    }

    /// Re-read durations from settings; refresh remaining if idle.
    func applySettingsChange() {
        guard !isRunning else { return }
        remaining = settings.duration(for: session)
    }

    /// Reconcile state when the app returns to the foreground. The deadline may
    /// have passed while suspended, in which case we roll the session forward.
    func syncFromForeground() {
        guard isRunning else { return }
        syncRemaining()
        if remaining <= 0 {
            completeSession(playFeedback: false)
        }
    }

    // MARK: - Ticking

    private func scheduleTicker() {
        ticker = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }

    private func tick() {
        syncRemaining()
        if remaining <= 0 {
            completeSession(playFeedback: true)
        }
    }

    private func syncRemaining() {
        guard let deadline else { return }
        remaining = max(0, Int(deadline.timeIntervalSinceNow.rounded(.up)))
    }

    // MARK: - Transitions

    /// `playFeedback` is true only for foreground completion; when the app was
    /// suspended the scheduled notification already delivered the alert/sound.
    private func completeSession(playFeedback: Bool) {
        pause()
        if playFeedback && settings.haptics {
            haptics.sessionEnded()
        }
        advance(countingCurrent: true)
        if settings.autoStartNext {
            start()
        } else {
            liveActivity.end()
        }
    }

    private func advance(countingCurrent: Bool) {
        let next = nextSession(after: session, countingCurrent: countingCurrent)
        session = next
        remaining = settings.duration(for: next)
    }

    private func nextSession(after current: SessionType, countingCurrent: Bool) -> SessionType {
        switch current {
        case .focus:
            if countingCurrent { completedFocusSessions += 1 }
            let isCycleEnd = completedFocusSessions > 0
                && completedFocusSessions % settings.sessionsUntilLongBreak == 0
            return isCycleEnd ? .longBreak : .shortBreak
        case .shortBreak:
            return .focus
        case .longBreak:
            completedFocusSessions = 0
            return .focus
        }
    }
}
