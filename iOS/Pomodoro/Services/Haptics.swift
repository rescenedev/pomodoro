import UIKit

/// Thin wrapper around the system haptic feedback generator.
@MainActor
final class Haptics {
    private let generator = UINotificationFeedbackGenerator()

    /// Fired when a session completes in the foreground.
    func sessionEnded() {
        generator.notificationOccurred(.success)
    }

    /// Light tap for control button presses.
    func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
