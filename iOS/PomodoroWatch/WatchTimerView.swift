import SwiftUI

/// Dead-simple watchOS timer: one big tappable countdown. Tap anywhere to
/// start/pause. Switch session from the top menu. A slim bar shows progress.
struct WatchTimerView: View {
    @ObservedObject var timer: PomodoroTimer
    @ObservedObject var settings: PomodoroSettings
    @State private var pickingSession = false

    private var accent: SessionType { timer.session }

    var body: some View {
        NavigationStack {
            VStack(spacing: 4) {
                Spacer(minLength: 0)

                Text(timer.formattedRemaining)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .foregroundStyle(timer.isRunning
                        ? AnyShapeStyle(accent.gradient)
                        : AnyShapeStyle(Color.primary))
                    .contentTransition(.numericText())
                    .animation(.snappy, value: timer.formattedRemaining)

                Text(timer.session.title.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                progressBar
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 8)
            .padding(.bottom, 6)
            .contentShape(Rectangle())
            .onTapGesture { timer.toggle() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        pickingSession = true
                    } label: {
                        Image(systemName: accent.symbolName)
                            .foregroundStyle(accent.accentColor)
                    }
                }
            }
            .confirmationDialog("Session", isPresented: $pickingSession, titleVisibility: .visible) {
                ForEach(SessionType.allCases) { session in
                    Button(session.title) { timer.select(session) }
                }
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.12))
                Capsule().fill(accent.gradient)
                    .frame(width: geo.size.width * timer.progress)
            }
        }
        .frame(height: 4)
        .animation(.linear(duration: 0.25), value: timer.progress)
    }
}
