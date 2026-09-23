import AuxCanvasCore
import Foundation

/// Role: derived counts. FullMarks, total rings, longest span, consecutive-day streak.
public struct AuxStats: Hashable, Sendable, Equatable {
    public var fullMarkCount: Int
    public var ringLayerCount: Int
    public var longestRingSeconds: Int
    public var consecutiveDayStreak: Int

    public init(
        fullMarkCount: Int,
        ringLayerCount: Int,
        longestRingSeconds: Int,
        consecutiveDayStreak: Int
    ) {
        self.fullMarkCount = fullMarkCount
        self.ringLayerCount = ringLayerCount
        self.longestRingSeconds = longestRingSeconds
        self.consecutiveDayStreak = consecutiveDayStreak
    }

    public static let empty = AuxStats(
        fullMarkCount: 0,
        ringLayerCount: 0,
        longestRingSeconds: 0,
        consecutiveDayStreak: 0
    )
}

public enum StatsAggregator {
    public static func assemble(
        canvases: [AuxCanvasStrata],
        now: Date,
        calendar: Calendar
    ) -> AuxStats {
        let fullMarks = canvases.filter(\.isSealed).count
        let rings = canvases.flatMap(\.rings)
        let longest = rings.map(\.duration.seconds).max() ?? 0
        let marked = Set(canvases.filter { !$0.rings.isEmpty }.map(\.dayKey))
        return AuxStats(
            fullMarkCount: fullMarks,
            ringLayerCount: rings.count,
            longestRingSeconds: longest,
            consecutiveDayStreak: DayStreak.consecutive(marked: marked, now: now, calendar: calendar)
        )
    }
}
