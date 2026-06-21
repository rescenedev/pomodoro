import SwiftUI

/// Settings sheet for durations and behavior.
struct SettingsView: View {
    @ObservedObject var settings: PomodoroSettings
    @Environment(\.dismiss) private var dismiss
    @State private var player = SoundPlayer()
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Settings")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                Button {
                    onChange()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.primary.opacity(0.08)))
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
            }

            card(title: "Durations") {
                stepperRow("Focus", value: $settings.focusMinutes, range: 1...90, unit: "min", tint: SessionType.focus.accentColor)
                Divider().opacity(0.4)
                stepperRow("Short Break", value: $settings.shortBreakMinutes, range: 1...30, unit: "min", tint: SessionType.shortBreak.accentColor)
                Divider().opacity(0.4)
                stepperRow("Long Break", value: $settings.longBreakMinutes, range: 1...60, unit: "min", tint: SessionType.longBreak.accentColor)
            }

            card(title: "Cycle") {
                stepperRow("Sessions until long break", value: $settings.sessionsUntilLongBreak, range: 2...8, unit: "", tint: .secondary)
            }

            card(title: "Behavior") {
                ToggleRow(label: "Auto-start next session", isOn: $settings.autoStartNext, tint: SessionType.focus.accentColor)
            }

            card(title: "Sound") {
                SoundSettingsSection(
                    settings: settings,
                    player: player,
                    tint: SessionType.focus.accentColor
                )
            }
        }
        .padding(22)
        .frame(width: 360)
        .background(Color.clear.background(.ultraThinMaterial).ignoresSafeArea())
        .onChange(of: settings.focusMinutes) { _, _ in onChange() }
        .onChange(of: settings.shortBreakMinutes) { _, _ in onChange() }
        .onChange(of: settings.longBreakMinutes) { _, _ in onChange() }
    }

    // MARK: - Building blocks

    private func card<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)
            VStack(spacing: 10) {
                content()
            }
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )
        }
    }

    private func stepperRow(_ label: String, value: Binding<Int>, range: ClosedRange<Int>, unit: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 13))
            Spacer(minLength: 8)
            NumericField(value: value, range: range, tint: tint)
            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Stepper("", value: value, in: range)
                .labelsHidden()
        }
    }
}
