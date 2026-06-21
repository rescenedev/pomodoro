import Foundation
import UserNotifications

/// Schedules the end-of-session local notification on watchOS. Same API as the
/// iOS service so the shared `PomodoroTimer` compiles unchanged.
@MainActor
final class NotificationService {
    private static let pendingID = "session-end"
    private var authorized = false

    func requestAuthorization() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _ in
                Task { @MainActor in self.authorized = granted }
            }
    }

    func scheduleSessionEnd(_ session: SessionType, at deadline: Date, playSound: Bool) {
        cancelScheduled()
        let interval = deadline.timeIntervalSinceNow
        guard interval > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(session.title) complete"
        content.body = session.isFocus
            ? "Nice work — time for a break."
            : "Break's over — back to focus."
        content.sound = playSound ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: Self.pendingID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelScheduled() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.pendingID])
    }
}
