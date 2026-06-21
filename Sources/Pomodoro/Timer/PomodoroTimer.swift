import Foundation
import Combine

/// Drives the Pomodoro countdown and session transitions.
@MainActor
final class PomodoroTimer: ObservableObject {
    @Published private(set) var session: SessionType = .focus
    @Published private(set) var remaining: Int
    @Published private(set) var isRunning = false
    /// Number of focus sessions completed in the current long-break cycle.
    @Published private(set) var completedFocusSessions = 0

    private let settings: PomodoroSettings
    private let notifier: NotificationService
    private var ticker: AnyCancellable?
    /// Wall-clock deadline; recomputed on every start/resume to avoid timer drift.
    private var deadline: Date?

    init(settings: PomodoroSettings, notifier: NotificationService) {
        self.settings = settings
        self.notifier = notifier
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
        deadline = Date().addingTimeInterval(TimeInterval(remaining))
        scheduleTicker()
    }

    func pause() {
        guard isRunning else { return }
        syncRemaining()
        isRunning = false
        deadline = nil
        ticker?.cancel()
        ticker = nil
    }

    /// Reset the current session back to its full duration.
    func reset() {
        pause()
        remaining = settings.duration(for: session)
    }

    /// Skip to the next session in the cycle without completing the current one.
    func skip() {
        pause()
        advance(countingCurrent: false)
    }

    /// Manually switch to a specific session type (resets the countdown).
    func select(_ newSession: SessionType) {
        guard newSession != session else { return }
        pause()
        session = newSession
        remaining = settings.duration(for: newSession)
    }

    /// Force a specific visual state — used only by the preview renderer.
    func applyPreview(session: SessionType, remaining: Int, running: Bool, completedFocus: Int) {
        self.session = session
        self.remaining = remaining
        self.isRunning = running
        self.completedFocusSessions = completedFocus
    }

    /// Re-read durations from settings; refresh remaining if idle.
    func applySettingsChange() {
        guard !isRunning else { return }
        remaining = settings.duration(for: session)
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
            completeSession()
        }
    }

    private func syncRemaining() {
        guard let deadline else { return }
        remaining = max(0, Int(deadline.timeIntervalSinceNow.rounded(.up)))
    }

    // MARK: - Transitions

    private func completeSession() {
        let finished = session
        pause()
        notifier.notifySessionEnded(finished, playSound: settings.playSound, soundName: settings.soundName)
        advance(countingCurrent: true)
        if settings.autoStartNext {
            start()
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
