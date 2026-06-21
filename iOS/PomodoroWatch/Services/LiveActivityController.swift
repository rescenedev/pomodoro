import Foundation

/// watchOS has no Live Activities; this no-op keeps the shared `PomodoroTimer`
/// API-compatible across platforms.
@MainActor
final class LiveActivityController {
    func start(session: SessionType, deadline: Date) {}
    func pause(session: SessionType, remaining: Int) {}
    func end() {}
}
