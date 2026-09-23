import Foundation

/// Role: leaving Guided mid-cycle. Returns to Idle with no RingLayer so the strata stay ascending.
public struct AbandonMark: Hashable, Sendable, Codable {
    public var dayKey: DayKey
    public var createdAt: Date
    public var leftPhase: CanvasPhase

    public init(dayKey: DayKey, createdAt: Date, leftPhase: CanvasPhase) {
        self.dayKey = dayKey
        self.createdAt = createdAt
        self.leftPhase = leftPhase
    }
}
