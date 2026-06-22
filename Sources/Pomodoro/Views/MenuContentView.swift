import SwiftUI

/// The popover shown when the menu-bar item is clicked.
struct MenuContentView: View {
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject var settings: PomodoroSettings
    @Environment(\.openWindow) private var openWindow

    private var accent: SessionType { timer.session }

    var body: some View {
        VStack(spacing: 22) {
            SessionPicker(selection: timer.session) { timer.select($0) }
            timerRing
            sessionCounter
            controls
            footer
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .frame(width: 300)
        .background(backdrop)
    }

    // MARK: - Background

    private var backdrop: some View {
        ZStack {
            Color.clear.background(.ultraThinMaterial)
            accent.accentColor
                .opacity(0.16)
                .blur(radius: 60)
                .offset(y: -90)
                .animation(.easeInOut(duration: 0.4), value: timer.session)
        }
        .ignoresSafeArea()
    }

    // MARK: - Ring

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 12)

            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(
                    accent.gradient,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: accent.accentColor.opacity(0.5), radius: 8)
                .animation(.linear(duration: 0.25), value: timer.progress)

            VStack(spacing: 2) {
                Text(timer.formattedRemaining)
                    .font(.system(size: 46, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy, value: timer.formattedRemaining)
                Text(timer.session.title.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 184, height: 184)
    }

    // MARK: - Cycle dots

    private var sessionCounter: some View {
        HStack(spacing: 7) {
            ForEach(0..<settings.sessionsUntilLongBreak, id: \.self) { index in
                Capsule()
                    .fill(index < currentCycleCount ? AnyShapeStyle(SessionType.focus.gradient) : AnyShapeStyle(Color.primary.opacity(0.12)))
                    .frame(width: index < currentCycleCount ? 18 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentCycleCount)
            }
        }
    }

    private var currentCycleCount: Int {
        timer.completedFocusSessions % settings.sessionsUntilLongBreak
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 22) {
            CircleControlButton(
                systemName: "arrow.counterclockwise",
                size: 44,
                action: timer.reset
            )
            .help("Reset")

            PrimaryControlButton(
                systemName: timer.isRunning ? "pause.fill" : "play.fill",
                gradient: accent.gradient,
                glow: accent.accentColor,
                action: timer.toggle
            )
            .help(timer.isRunning ? "Pause" : "Start")

            CircleControlButton(
                systemName: "forward.fill",
                size: 44,
                action: timer.skip
            )
            .help("Skip")
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 14) {
            footerIcon("gearshape.fill", help: "Settings") {
                SettingsWindow.activate()
                openWindow(id: SettingsWindow.id)
            }
            footerIcon("chart.bar.fill", help: "Statistics") {
                SettingsWindow.activate()
                openWindow(id: AuxWindow.stats)
            }
            footerIcon("pin.fill", help: "Float on top") {
                SettingsWindow.activate()
                openWindow(id: AuxWindow.floating)
            }
            Spacer()
            footerIcon("power", help: "Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.top, 2)
    }

    private func footerIcon(_ systemName: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 30, height: 26)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
