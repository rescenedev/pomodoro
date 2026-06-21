import SwiftUI

@main
struct PomodoroApp: App {
    @StateObject private var settings: PomodoroSettings
    @StateObject private var timer: PomodoroTimer
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let settings = PomodoroSettings()
        let notifier = NotificationService()
        notifier.requestAuthorization()
        let haptics = Haptics()
        let liveActivity = LiveActivityController()
        _settings = StateObject(wrappedValue: settings)
        _timer = StateObject(wrappedValue: PomodoroTimer(
            settings: settings,
            notifier: notifier,
            haptics: haptics,
            liveActivity: liveActivity
        ))
    }

    var body: some Scene {
        WindowGroup {
            TimerView(timer: timer, settings: settings)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                timer.syncFromForeground()
            }
        }
    }
}
