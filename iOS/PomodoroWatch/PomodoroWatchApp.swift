import SwiftUI

@main
struct PomodoroWatchApp: App {
    @StateObject private var settings: PomodoroSettings
    @StateObject private var timer: PomodoroTimer
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let settings = PomodoroSettings()
        let notifier = NotificationService()
        notifier.requestAuthorization()
        let timer = PomodoroTimer(
            settings: settings,
            notifier: notifier,
            haptics: Haptics(),
            liveActivity: LiveActivityController()
        )
        _settings = StateObject(wrappedValue: settings)
        _timer = StateObject(wrappedValue: timer)
    }

    var body: some Scene {
        WindowGroup {
            WatchTimerView(timer: timer, settings: settings)
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { timer.syncFromForeground() }
        }
    }
}
