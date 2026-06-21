import Foundation
import UserNotifications
import AppKit

/// Posts a local notification (and optional sound) when a session ends.
@MainActor
final class NotificationService {
    private var authorized = false
    private let soundPlayer = SoundPlayer()

    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _ in
                Task { @MainActor in self.authorized = granted }
            }
    }

    func notifySessionEnded(_ finished: SessionType, playSound: Bool, soundName: String) {
        if playSound {
            soundPlayer.play(soundName)
        }
        postNotification(for: finished)
    }

    private func postNotification(for finished: SessionType) {
        guard authorized else { return }
        let content = UNMutableNotificationContent()
        content.title = "\(finished.title) complete"
        content.body = finished.isFocus
            ? "Nice work — time for a break."
            : "Break's over — back to focus."
        content.sound = nil // sound handled by NSSound for reliability in menu-bar apps

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
