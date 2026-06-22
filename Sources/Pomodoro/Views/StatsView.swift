import SwiftUI

/// Today / this week / this month focus-session rollups.
struct StatsView: View {
    @ObservedObject var stats: StatsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Statistics")
                .font(.system(size: 20, weight: .bold, design: .rounded))

            row("Today", stats.today, tint: SessionType.focus.accentColor)
            row("This Week", stats.week, tint: SessionType.shortBreak.accentColor)
            row("This Month", stats.month, tint: SessionType.longBreak.accentColor)
        }
        .padding(22)
        .frame(width: 320)
        .background(Color.clear.background(.ultraThinMaterial).ignoresSafeArea())
    }

    private func row(_ label: String, _ summary: StatsStore.Summary, tint: Color) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
                Text(focusTime(summary.minutes))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(summary.count)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(tint)
                Text("🍅").font(.system(size: 16))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }

    private func focusTime(_ minutes: Int) -> String {
        guard minutes > 0 else { return "no focus yet" }
        if minutes < 60 { return "\(minutes)m focused" }
        return "\(minutes / 60)h \(minutes % 60)m focused"
    }
}
