import SwiftUI

/// The full-screen timer interface.
struct TimerView: View {
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject var settings: PomodoroSettings
    @State private var showingSettings = false

    private var accent: SessionType { timer.session }

    var body: some View {
        ZStack {
            backdrop
            VStack(spacing: 0) {
                header
                Spacer().frame(height: 24)
                SessionPicker(selection: timer.session) { timer.select($0) }
                    .padding(.horizontal, 32)
                Spacer(minLength: 28)
                timerRing
                Spacer().frame(height: 28)
                sessionCounter
                Spacer(minLength: 28)
                controls
            }
            .padding(.top, 24)
            .padding(.bottom, 16)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings) { timer.applySettingsChange() }
        }
    }

    // MARK: - Background

    private var backdrop: some View {
        ZStack {
            Color(.systemBackground)
            accent.accentColor
                .opacity(0.18)
                .blur(radius: 90)
                .offset(y: -160)
                .animation(.easeInOut(duration: 0.5), value: timer.session)
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Pomodoro")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Spacer()
            CircleControlButton(systemName: "gearshape.fill", size: 44) {
                showingSettings = true
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Ring

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.08), lineWidth: 18)

            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(
                    accent.gradient,
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: accent.accentColor.opacity(0.5), radius: 10)
                .animation(.linear(duration: 0.25), value: timer.progress)

            VStack(spacing: 4) {
                Text(timer.formattedRemaining)
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy, value: timer.formattedRemaining)
                Text(timer.session.title.uppercased())
                    .font(.system(size: 14, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 280, height: 280)
    }

    // MARK: - Cycle dots

    private var sessionCounter: some View {
        HStack(spacing: 10) {
            ForEach(0..<settings.sessionsUntilLongBreak, id: \.self) { index in
                Capsule()
                    .fill(index < currentCycleCount
                          ? AnyShapeStyle(SessionType.focus.gradient)
                          : AnyShapeStyle(Color.primary.opacity(0.12)))
                    .frame(width: index < currentCycleCount ? 26 : 11, height: 11)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentCycleCount)
            }
        }
    }

    private var currentCycleCount: Int {
        timer.completedFocusSessions % settings.sessionsUntilLongBreak
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 36) {
            CircleControlButton(systemName: "arrow.counterclockwise", size: 60, action: timer.reset)
            PrimaryControlButton(
                systemName: timer.isRunning ? "pause.fill" : "play.fill",
                gradient: accent.gradient,
                glow: accent.accentColor,
                action: timer.toggle
            )
            CircleControlButton(systemName: "forward.fill", size: 60, action: timer.skip)
        }
    }
}
