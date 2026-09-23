import Foundation

/// Role: AuxCanvasStrata. The day canvas as an ordered center-out Ring stack keyed by daykey.
public struct AuxCanvasStrata: Hashable, Sendable, Codable {
    public var dayKey: DayKey
    public var phase: CanvasPhase
    public var rings: [Ring]
    public var pendingPace: PaceHold?
    public var guided: GuidedRound?
    public var fullMark: FullMark?
    public var clearedAt: Date?

    public init(
        dayKey: DayKey,
        phase: CanvasPhase = .idle,
        rings: [Ring] = [],
        pendingPace: PaceHold? = nil,
        guided: GuidedRound? = nil,
        fullMark: FullMark? = nil,
        clearedAt: Date? = nil
    ) {
        self.dayKey = dayKey
        self.phase = phase
        self.rings = rings
        self.pendingPace = pendingPace
        self.guided = guided
        self.fullMark = fullMark
        self.clearedAt = clearedAt
    }

    public var isSealed: Bool { fullMark != nil }
    public var isClear: Bool { rings.isEmpty && fullMark == nil }
    public var ringCount: Int { rings.count }
    public var outermostDuration: RoundDuration? { rings.last?.duration }

    public var asClear: Clear? {
        isClear ? Clear(dayKey: dayKey) : nil
    }

    public static func empty(dayKey: DayKey) -> AuxCanvasStrata {
        AuxCanvasStrata(dayKey: dayKey)
    }

    public static func seeded(dayKey: DayKey, at date: Date) -> AuxCanvasStrata {
        let seed = Ring(
            index: 0,
            duration: .thinSeed,
            pace: PaceHold(millis: 1000),
            createdAt: date,
            isSeed: true
        )
        return AuxCanvasStrata(dayKey: dayKey, rings: [seed])
    }
}
