import SwiftUI

struct PomodoroApp: App {
    @StateObject private var settings: PomodoroSettings
    @StateObject private var timer: PomodoroTimer
    @StateObject private var stats: StatsStore
    private let notifier: NotificationService

    init() {
        let settings = PomodoroSettings()
        let notifier = NotificationService()
        notifier.requestAuthorization()
        let stats = StatsStore()
        _settings = StateObject(wrappedValue: settings)
        _stats = StateObject(wrappedValue: stats)
        _timer = StateObject(wrappedValue: PomodoroTimer(settings: settings, notifier: notifier, stats: stats))
        self.notifier = notifier
    }

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(timer: timer, settings: settings)
        } label: {
            MenuBarLabel(timer: timer)
        }
        .menuBarExtraStyle(.window)

        Window("Pomodoro Settings", id: SettingsWindow.id) {
            SettingsView(settings: settings) {
                timer.applySettingsChange()
            }
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .windowStyle(.hiddenTitleBar)

        Window("Statistics", id: AuxWindow.stats) {
            StatsView(stats: stats)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .windowStyle(.hiddenTitleBar)

        Window("Pomodoro", id: AuxWindow.floating) {
            FloatingTimerView(timer: timer)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.topTrailing)
        .windowStyle(.hiddenTitleBar)
    }
}

/// Identifiers for the auxiliary windows opened from the menu.
enum AuxWindow {
    static let stats = "stats"
    static let floating = "floating"
}

/// Identifiers/helpers for the dedicated settings window.
enum SettingsWindow {
    static let id = "settings"

    /// Bring the app forward so the settings window can become key.
    @MainActor static func activate() {
        NSApp.activate(ignoringOtherApps: true)
    }
}

/// The compact label rendered in the system menu bar.
private struct MenuBarLabel: View {
    @ObservedObject var timer: PomodoroTimer

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: timer.session.symbolName)
            if timer.isRunning {
                Text(timer.formattedRemaining)
                    .monospacedDigit()
            }
        }
    }
}
