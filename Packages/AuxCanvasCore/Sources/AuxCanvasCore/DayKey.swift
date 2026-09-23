import Foundation

/// Role: the day canvas key. Built from Calendar.startOfDay components, never from a formatted date string.
public struct DayKey: Hashable, Sendable, Comparable, Codable {
    public let raw: Int32

    public init(raw: Int32) {
        self.raw = raw
    }

    public static func of(_ date: Date, calendar: Calendar = .current) -> DayKey {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return DayKey(raw: Int32(year * 10_000 + month * 100 + day))
    }

    public func startDate(calendar: Calendar = .current) -> Date? {
        var parts = DateComponents()
        parts.year = Int(raw / 10_000)
        parts.month = Int((raw / 100) % 100)
        parts.day = Int(raw % 100)
        guard let date = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: date)
    }

    public func previous(calendar: Calendar = .current) -> DayKey? {
        guard let start = startDate(calendar: calendar),
              let prior = calendar.date(byAdding: .day, value: -1, to: start)
        else { return nil }
        return DayKey.of(prior, calendar: calendar)
    }

    public func next(calendar: Calendar = .current) -> DayKey? {
        guard let start = startDate(calendar: calendar),
              let following = calendar.date(byAdding: .day, value: 1, to: start)
        else { return nil }
        return DayKey.of(following, calendar: calendar)
    }

    public static func < (lhs: DayKey, rhs: DayKey) -> Bool {
        lhs.raw < rhs.raw
    }
}

/// Role: consecutive-day streak walked backward over marked daykeys from today.
public enum DayStreak {
    public static func consecutive(
        marked: Set<DayKey>,
        now: Date,
        calendar: Calendar = .current
    ) -> Int {
        var cursor = DayKey.of(now, calendar: calendar)
        if !marked.contains(cursor) {
            guard let yesterday = cursor.previous(calendar: calendar), marked.contains(yesterday) else {
                return 0
            }
            cursor = yesterday
        }
        var length = 0
        while marked.contains(cursor) {
            length += 1
            guard let prior = cursor.previous(calendar: calendar) else { break }
            cursor = prior
        }
        return length
    }
}
