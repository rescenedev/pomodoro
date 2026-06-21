import SwiftUI

/// Compact watchOS timer: session pills, progress ring, start/pause + reset.
struct WatchTimerView: View {
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject var settings: PomodoroSettings

    private var accent: SessionType { timer.session }

    var body: some View {
        VStack(spacing: 5) {
            sessionPills
            ring
            controls
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 2)
        .containerBackground(accent.accentColor.opacity(0.18).gradient, for: .navigation)
    }

    private var sessionPills: some View {
        HStack(spacing: 3) {
            ForEach(SessionType.allCases) { session in
                let selected = session == timer.session
                Text(session.shortTitle)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 3)
                    .background { if selected { Capsule().fill(session.gradient) } }
                    .foregroundStyle(selected ? .white : .secondary)
                    .contentShape(Capsule())
                    .onTapGesture { timer.select(session) }
            }
        }
    }

    private var ring: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.15), lineWidth: 6)
            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(accent.gradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: timer.progress)
            VStack(spacing: 0) {
                Text(timer.formattedRemaining)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.snappy, value: timer.formattedRemaining)
                Text(timer.session.title.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxHeight: .infinity)
        .onTapGesture { timer.toggle() }
    }

    private var controls: some View {
        HStack(spacing: 8) {
            Button(action: timer.reset) {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
            .tint(.gray)
            .frame(width: 48)

            Button(action: timer.toggle) {
                Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(accent.accentColor)
        }
    }
}
