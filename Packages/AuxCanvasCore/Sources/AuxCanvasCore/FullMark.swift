import Foundation

/// Role: FullMarkSeal. The seventh ring stamp that makes a day canvas read only.
public struct FullMark: Hashable, Sendable, Codable {
    public var dayKey: DayKey
    public var createdAt: Date

    public init(dayKey: DayKey, createdAt: Date) {
        self.dayKey = dayKey
        self.createdAt = createdAt
    }
}

public enum FullMarkSeal {
    public static let ringCapacity = 7

    public static func shouldSeal(ringCount: Int) -> Bool {
        ringCount >= ringCapacity
    }
}
