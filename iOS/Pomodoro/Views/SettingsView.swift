import SwiftUI

/// Settings sheet for durations and behavior.
struct SettingsView: View {
    @ObservedObject var settings: PomodoroSettings
    @Environment(\.dismiss) private var dismiss
    let onChange: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Durations") {
                    stepperRow("Focus", value: $settings.focusMinutes, range: 1...90, tint: SessionType.focus.accentColor)
                    stepperRow("Short Break", value: $settings.shortBreakMinutes, range: 1...30, tint: SessionType.shortBreak.accentColor)
                    stepperRow("Long Break", value: $settings.longBreakMinutes, range: 1...60, tint: SessionType.longBreak.accentColor)
                }

                Section("Cycle") {
                    stepperRow("Sessions until long break", value: $settings.sessionsUntilLongBreak, range: 2...8, tint: .secondary, unit: false)
                }

                Section("Behavior") {
                    ToggleRow(label: "Auto-start next session", isOn: $settings.autoStartNext, tint: SessionType.focus.accentColor)
                }

                Section("Alerts") {
                    ToggleRow(label: "Notification sound", isOn: $settings.playSound, tint: SessionType.focus.accentColor)
                    ToggleRow(label: "Haptics", isOn: $settings.haptics, tint: SessionType.focus.accentColor)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onChange()
                        dismiss()
                    }
                }
            }
            .onChange(of: settings.focusMinutes) { _, _ in onChange() }
            .onChange(of: settings.shortBreakMinutes) { _, _ in onChange() }
            .onChange(of: settings.longBreakMinutes) { _, _ in onChange() }
        }
    }

    private func stepperRow(_ label: String, value: Binding<Int>, range: ClosedRange<Int>, tint: Color, unit: Bool = true) -> some View {
        Stepper(value: value, in: range) {
            HStack {
                Text(label)
                Spacer()
                Text(unit ? "\(value.wrappedValue) min" : "\(value.wrappedValue)")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(tint)
            }
        }
    }
}
