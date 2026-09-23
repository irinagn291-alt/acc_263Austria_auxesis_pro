import Foundation

/// Role: a day with no rings. Empty canvas writes Clear; seed replaces it with one thin Ring.
public struct Clear: Hashable, Sendable, Codable {
    public var dayKey: DayKey

    public init(dayKey: DayKey) {
        self.dayKey = dayKey
    }
}
