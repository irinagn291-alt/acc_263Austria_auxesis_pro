import Foundation

/// Role: the completed exhale written onto the strata. Seed rings are also stored as layers.
public struct RingLayer: Hashable, Sendable, Codable {
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

    public func asRing() -> Ring {
        Ring(index: index, duration: duration, pace: pace, createdAt: createdAt, isSeed: isSeed)
    }

    public static func from(_ ring: Ring) -> RingLayer {
        RingLayer(
            index: ring.index,
            duration: ring.duration,
            pace: ring.pace,
            createdAt: ring.createdAt,
            isSeed: ring.isSeed
        )
    }
}

/// Role: RingLayerFold. Completing the final exhale appends a layer and may stamp a FullMark.
public enum RingLayerFold {
    public static func commit(on canvas: AuxCanvasStrata, at date: Date) -> FoldResult {
        guard canvas.phase == .guided, let guided = canvas.guided else {
            return FoldResult(canvas: canvas, refusal: .notGuided)
        }
        if canvas.isSealed {
            return FoldResult(canvas: canvas, refusal: .canvasSealed)
        }
        if canvas.rings.count >= FullMarkSeal.ringCapacity {
            return FoldResult(canvas: canvas, refusal: .canvasSealed)
        }
        let layer = RingLayer(
            index: canvas.rings.count,
            duration: guided.duration,
            pace: guided.pace,
            createdAt: date,
            isSeed: false
        )
        var next = canvas
        next.rings.append(layer.asRing())
        next.phase = .idle
        next.pendingPace = nil
        next.guided = nil
        var full: FullMark?
        if FullMarkSeal.shouldSeal(ringCount: next.rings.count) {
            full = FullMark(dayKey: canvas.dayKey, createdAt: date)
            next.fullMark = full
        }
        return FoldResult(canvas: next, writtenLayer: layer, fullMark: full)
    }
}
