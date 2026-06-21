import ActivityKit
import Foundation

/// Shared between the app (which starts/updates the activity) and the widget
/// extension (which renders it on the Lock Screen and in the Dynamic Island).
struct PomodoroActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// SessionType.rawValue — the widget rebuilds the SessionType for colors.
        var sessionRawValue: String
        var sessionTitle: String
        var symbolName: String
        /// When the current session ends; drives the auto-counting timer text.
        var deadline: Date
        var isRunning: Bool
        /// Frozen seconds remaining, shown while paused.
        var remaining: Int
    }
}
