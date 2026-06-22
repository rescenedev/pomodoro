import SwiftUI
import AppKit

/// Compact always-on-top timer panel.
struct FloatingTimerView: View {
    @ObservedObject var timer: PomodoroTimer

    private var accent: SessionType { timer.session }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().stroke(Color.primary.opacity(0.08), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(accent.gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.25), value: timer.progress)
                VStack(spacing: 1) {
                    Text(timer.formattedRemaining)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.snappy, value: timer.formattedRemaining)
                    Text(timer.session.title.uppercased())
                        .font(.system(size: 8, weight: .semibold))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 116, height: 116)

            HStack(spacing: 14) {
                CircleControlButton(systemName: "arrow.counterclockwise", size: 30, action: timer.reset)
                Button(action: timer.toggle) {
                    Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(accent.gradient))
                        .shadow(color: accent.accentColor.opacity(0.45), radius: 6)
                }
                .buttonStyle(.plain)
                CircleControlButton(systemName: "forward.fill", size: 30, action: timer.skip)
            }
        }
        .padding(16)
        .frame(width: 184)
        .background(Color.clear.background(.ultraThinMaterial).ignoresSafeArea())
        .background(FloatingWindowConfigurator())
    }
}

/// Grabs the hosting NSWindow and makes it a borderless always-on-top panel.
private struct FloatingWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.isMovableByWindowBackground = true
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
