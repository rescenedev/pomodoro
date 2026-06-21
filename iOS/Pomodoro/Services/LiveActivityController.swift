import ActivityKit
import Foundation

/// Manages the running-timer Live Activity (Lock Screen + Dynamic Island).
///
/// A countdown is shown with `Text(timerInterval:)` in the widget, so the system
/// animates it down to zero with no per-second updates from the app. We only push
/// an update when the run state changes (pause/resume) or the session changes.
///
/// `Activity` handles are non-Sendable, so rather than retaining one we always
/// drive the live set via the nonisolated `Activity.activities` collection.
@MainActor
final class LiveActivityController {
    private var enabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    /// Begin (or replace) the activity for a freshly started session.
    func start(session: SessionType, deadline: Date) {
        guard enabled else { return }
        let state = Self.makeState(session: session, deadline: deadline, isRunning: true, remaining: 0)
        Task {
            await Self.endAll()
            _ = try? Activity.request(
                attributes: PomodoroActivityAttributes(),
                content: .init(state: state, staleDate: deadline),
                pushType: nil
            )
        }
    }

    /// Reflect a pause: freeze the displayed time and stop the auto-counter.
    func pause(session: SessionType, remaining: Int) {
        let state = Self.makeState(session: session, deadline: Date(), isRunning: false, remaining: remaining)
        Task { await Self.updateAll(state) }
    }

    /// Tear the activity down (timer stopped or session changed without a restart).
    func end() {
        Task { await Self.endAll() }
    }

    // MARK: - Nonisolated ActivityKit work

    nonisolated private static func updateAll(_ state: PomodoroActivityAttributes.ContentState) async {
        for activity in Activity<PomodoroActivityAttributes>.activities {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    nonisolated private static func endAll() async {
        for activity in Activity<PomodoroActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    nonisolated private static func makeState(
        session: SessionType, deadline: Date, isRunning: Bool, remaining: Int
    ) -> PomodoroActivityAttributes.ContentState {
        PomodoroActivityAttributes.ContentState(
            sessionRawValue: session.rawValue,
            sessionTitle: session.title,
            symbolName: session.symbolName,
            deadline: deadline,
            isRunning: isRunning,
            remaining: remaining
        )
    }
}
