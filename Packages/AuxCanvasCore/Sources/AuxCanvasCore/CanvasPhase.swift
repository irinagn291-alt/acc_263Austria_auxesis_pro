import Foundation

/// Role: the three-phase fold. Idle waits, Pacing holds a Pace, Guided runs the breath cycle.
public enum CanvasPhase: String, Hashable, Sendable, Codable {
    case idle
    case pacing
    case guided
}

/// Role: inhale grows, hold rests, exhale shrinks. Scale 0.55 to 1, then 1 to 0.55.
public enum GuidedPhase: String, Hashable, Sendable, Codable {
    case inhale
    case hold
    case exhale

    public var scaleFrom: Double {
        switch self {
        case .inhale: 0.55
        case .hold: 1
        case .exhale: 1
        }
    }

    public var scaleTo: Double {
        switch self {
        case .inhale: 1
        case .hold: 1
        case .exhale: 0.55
        }
    }
}

/// Role: the in-progress breath session after a swipe. Locked pace and duration until the final exhale.
public struct GuidedRound: Hashable, Sendable, Codable {
    public var pace: PaceHold
    public var duration: RoundDuration
    public var pattern: BreathPattern
    public var phase: GuidedPhase

    public init(
        pace: PaceHold,
        duration: RoundDuration,
        pattern: BreathPattern = .calm,
        phase: GuidedPhase = .inhale
    ) {
        self.pace = pace
        self.duration = duration
        self.pattern = pattern
        self.phase = phase
    }
}
