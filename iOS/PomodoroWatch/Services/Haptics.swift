import WatchKit

/// watchOS haptics via the Taptic Engine. Same API as the iOS `Haptics`
/// so the shared `PomodoroTimer` compiles unchanged.
@MainActor
final class Haptics {
    func sessionEnded() {
        WKInterfaceDevice.current().play(.success)
    }

    func tap() {
        WKInterfaceDevice.current().play(.click)
    }
}
