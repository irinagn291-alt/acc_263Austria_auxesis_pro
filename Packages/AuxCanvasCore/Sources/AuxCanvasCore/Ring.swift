import Foundation

/// Role: one center-out stratum on the day canvas. Duration must equal or exceed the ring inside it.
public struct Ring: Hashable, Sendable, Codable {
    public var index: Int
    public var duration: RoundDuration
    public var pace: PaceHold
    public var createdAt: Date
    public var isSeed: Bool

    public init(
        index: Int,
        duration: RoundDuration,
        pace: PaceHold,
        createdAt: Date,
        isSeed: Bool = false
    ) {
        self.index = index
        self.duration = duration
        self.pace = pace
        self.createdAt = createdAt
        self.isSeed = isSeed
    }
}
