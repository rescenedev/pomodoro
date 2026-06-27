import Foundation
import Combine

/// One completed focus session.
struct FocusRecord: Codable {
    let date: Date
    let minutes: Int
}

/// Records completed focus sessions and exposes today / week / month rollups,
/// persisted in UserDefaults.
@MainActor
final class StatsStore: ObservableObject {
    /// Aggregated count + total focus minutes over a window.
    struct Summary: Equatable {
        let count: Int
        let minutes: Int
    }

    @Published private(set) var records: [FocusRecord]

    private let defaults: UserDefaults
    private let key = "focusRecords"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([FocusRecord].self, from: data) {
            records = decoded
        } else {
            records = []
        }
    }

    /// Append a finished focus session.
    func recordFocus(minutes: Int, at date: Date = Date()) {
        records.append(FocusRecord(date: date, minutes: minutes))
        if let data = try? JSONEncoder().encode(records) {
            defaults.set(data, forKey: key)
        }
    }

    // MARK: - Rollups

    var today: Summary { summary(sinceDaysAgo: 0) }
    var week: Summary { summary(sinceDaysAgo: 6) }
    var month: Summary { summary(sinceDaysAgo: 29) }

    /// One completed-focus count per day for the last `days` days (oldest first).
    struct DayCount: Identifiable {
        let day: Date
        let count: Int
        var id: Date { day }
    }

    func dailyCounts(days: Int) -> [DayCount] {
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())
        return (0..<days).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: startOfToday) ?? startOfToday
            let next = cal.date(byAdding: .day, value: 1, to: day) ?? day
            let count = records.filter { $0.date >= day && $0.date < next }.count
            return DayCount(day: day, count: count)
        }
    }

    /// Records on/after the start of the day `daysAgo` days before today.
    private func summary(sinceDaysAgo daysAgo: Int) -> Summary {
        let cal = Calendar.current
        let startOfToday = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -daysAgo, to: startOfToday) ?? startOfToday
        let scoped = records.filter { $0.date >= start }
        return Summary(count: scoped.count, minutes: scoped.reduce(0) { $0 + $1.minutes })
    }
}
