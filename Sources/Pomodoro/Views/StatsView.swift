import SwiftUI
import Charts

/// Today / this week / this month focus-session rollups, with a 7-day chart.
struct StatsView: View {
    @ObservedObject var stats: StatsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Statistics")
                .font(.system(size: 20, weight: .bold, design: .rounded))

            chart

            row("Today", stats.today, tint: SessionType.focus.accentColor)
            row("This Week", stats.week, tint: SessionType.shortBreak.accentColor)
            row("This Month", stats.month, tint: SessionType.longBreak.accentColor)
        }
        .padding(22)
        .frame(width: 320)
        .background(Color.clear.background(.ultraThinMaterial).ignoresSafeArea())
    }

    private var chart: some View {
        let days = stats.dailyCounts(days: 7)
        let maxCount = max(days.map(\.count).max() ?? 0, 1)
        return VStack(alignment: .leading, spacing: 8) {
            Text("LAST 7 DAYS")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)
            Chart(days) { day in
                BarMark(
                    x: .value("Day", day.day, unit: .day),
                    y: .value("Pomodoros", day.count),
                    width: .fixed(18)
                )
                .clipShape(Capsule())
                .foregroundStyle(SessionType.focus.gradient)
            }
            .chartYScale(domain: 0...maxCount)
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(height: 96)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
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
            Text("\(summary.count)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(tint)
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
