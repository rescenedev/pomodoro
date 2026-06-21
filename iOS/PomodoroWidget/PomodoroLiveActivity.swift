import ActivityKit
import WidgetKit
import SwiftUI

/// Lock Screen banner + Dynamic Island presentation for the running timer.
struct PomodoroLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(Color.black.opacity(0.25))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            let session = SessionType(rawValue: context.state.sessionRawValue) ?? .focus
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text(session.title)
                            .font(.caption).fontWeight(.semibold)
                    } icon: {
                        Image(systemName: context.state.symbolName)
                            .foregroundStyle(session.accentColor)
                    }
                    .padding(.leading, 4)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    timeText(context.state, font: .title2)
                        .foregroundStyle(session.accentColor)
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(timerInterval: progressRange(context.state),
                                 countsDown: false,
                                 label: { EmptyView() },
                                 currentValueLabel: { EmptyView() })
                        .tint(session.accentColor)
                        .opacity(context.state.isRunning ? 1 : 0.4)
                }
            } compactLeading: {
                Image(systemName: context.state.symbolName)
                    .foregroundStyle(session.accentColor)
            } compactTrailing: {
                timeText(context.state, font: .caption2)
                    .foregroundStyle(session.accentColor)
                    .frame(maxWidth: 56)
            } minimal: {
                Image(systemName: context.state.symbolName)
                    .foregroundStyle(session.accentColor)
            }
            .keylineTint(session.accentColor)
        }
    }
}

// MARK: - Lock Screen

private struct LockScreenView: View {
    let state: PomodoroActivityAttributes.ContentState

    private var session: SessionType {
        SessionType(rawValue: state.sessionRawValue) ?? .focus
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(session.accentColor.opacity(0.18))
                Image(systemName: state.symbolName)
                    .font(.title2)
                    .foregroundStyle(session.accentColor)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.title.uppercased())
                    .font(.caption2).fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
                timeText(state, font: .system(size: 34, weight: .bold, design: .rounded))
            }

            Spacer()

            if !state.isRunning {
                Image(systemName: "pause.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - Shared helpers

/// Auto-counting time when running; frozen MM:SS when paused.
private func timeText(_ state: PomodoroActivityAttributes.ContentState, font: Font) -> some View {
    Group {
        if state.isRunning {
            Text(timerInterval: Date()...state.deadline, countsDown: true)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        } else {
            Text(formatted(state.remaining))
                .monospacedDigit()
        }
    }
    .font(font)
}

/// Elapsed-progress range for the bar: from "start" up to the deadline.
private func progressRange(_ state: PomodoroActivityAttributes.ContentState) -> ClosedRange<Date> {
    let now = Date()
    let start = min(now, state.deadline.addingTimeInterval(-1))
    return start...max(state.deadline, start.addingTimeInterval(1))
}

private func formatted(_ seconds: Int) -> String {
    let clamped = max(0, seconds)
    return String(format: "%02d:%02d", clamped / 60, clamped % 60)
}
