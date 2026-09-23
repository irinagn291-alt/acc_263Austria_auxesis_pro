import Foundation

/// Role: inputs to the phase-ring fold. Press writes Pace, swipe writes Duration, tap abandons Guided.
public enum CanvasEvent: Sendable, Equatable {
    case press(holdMillis: Int)
    case swipe(durationSeconds: Int)
    case completeExhale
    case abandon
}

/// Role: refusals that are part of the fold, not error handling bolted on.
public enum CanvasRefusal: Hashable, Sendable, Equatable {
    case swipeOnIdle
    case pressWhileGuided
    case pressTooShort
    case durationOutOfRange
    case durationBelowFloor(floorSeconds: Int)
    case canvasSealed
    case notGuided
    case alreadyGuided
}

/// Role: one fold step. Accepted mutations carry optional marks. Refusals keep the prior strata.
public struct FoldResult: Hashable, Sendable, Equatable {
    public var canvas: AuxCanvasStrata
    public var refusal: CanvasRefusal?
    public var writtenLayer: RingLayer?
    public var fullMark: FullMark?
    public var abandon: AbandonMark?

    public init(
        canvas: AuxCanvasStrata,
        refusal: CanvasRefusal? = nil,
        writtenLayer: RingLayer? = nil,
        fullMark: FullMark? = nil,
        abandon: AbandonMark? = nil
    ) {
        self.canvas = canvas
        self.refusal = refusal
        self.writtenLayer = writtenLayer
        self.fullMark = fullMark
        self.abandon = abandon
    }

    public var isAccepted: Bool { refusal == nil }

    public static func accepted(_ canvas: AuxCanvasStrata) -> FoldResult {
        FoldResult(canvas: canvas)
    }

    public static func refused(_ canvas: AuxCanvasStrata, _ refusal: CanvasRefusal) -> FoldResult {
        FoldResult(canvas: canvas, refusal: refusal)
    }
}

/// Role: the phase-ring reducer. Pure value type. No UIKit. No store import.
public enum CanvasFold {
    public static func apply(
        _ event: CanvasEvent,
        to canvas: AuxCanvasStrata,
        at date: Date
    ) -> FoldResult {
        if canvas.isSealed {
            return FoldResult.refused(canvas, .canvasSealed)
        }
        switch (canvas.phase, event) {
        case (.idle, .press(let millis)):
            return pressFromIdle(millis: millis, canvas: canvas)
        case (.idle, .swipe):
            return FoldResult.refused(canvas, .swipeOnIdle)
        case (.idle, .completeExhale):
            return FoldResult.refused(canvas, .notGuided)
        case (.idle, .abandon):
            return FoldResult.accepted(canvas)
        case (.pacing, .press(let millis)):
            return pressFromIdle(millis: millis, canvas: canvas)
        case (.pacing, .swipe(let seconds)):
            return swipeFromPacing(seconds: seconds, canvas: canvas)
        case (.pacing, .completeExhale):
            return FoldResult.refused(canvas, .notGuided)
        case (.pacing, .abandon):
            return cancelPacing(canvas)
        case (.guided, .press):
            return FoldResult.refused(canvas, .pressWhileGuided)
        case (.guided, .swipe):
            return FoldResult.refused(canvas, .alreadyGuided)
        case (.guided, .completeExhale):
            return RingLayerFold.commit(on: canvas, at: date)
        case (.guided, .abandon):
            return abandonGuided(canvas, at: date)
        }
    }

    private static func pressFromIdle(millis: Int, canvas: AuxCanvasStrata) -> FoldResult {
        guard let pace = PaceHold.fromHold(millis) else {
            return FoldResult.refused(canvas, .pressTooShort)
        }
        var next = canvas
        next.phase = .pacing
        next.pendingPace = pace
        next.guided = nil
        return FoldResult.accepted(next)
    }

    private static func swipeFromPacing(seconds: Int, canvas: AuxCanvasStrata) -> FoldResult {
        guard let pace = canvas.pendingPace else {
            return FoldResult.refused(canvas, .swipeOnIdle)
        }
        guard let duration = RoundDuration(seconds: seconds) else {
            return FoldResult.refused(canvas, .durationOutOfRange)
        }
        if let floor = canvas.outermostDuration, duration < floor {
            return FoldResult.refused(canvas, .durationBelowFloor(floorSeconds: floor.seconds))
        }
        if canvas.rings.count >= FullMarkSeal.ringCapacity {
            return FoldResult.refused(canvas, .canvasSealed)
        }
        var next = canvas
        next.phase = .guided
        next.guided = GuidedRound(pace: pace, duration: duration, pattern: .calm, phase: .inhale)
        return FoldResult.accepted(next)
    }

    private static func cancelPacing(_ canvas: AuxCanvasStrata) -> FoldResult {
        var next = canvas
        next.phase = .idle
        next.pendingPace = nil
        next.guided = nil
        return FoldResult.accepted(next)
    }

    private static func abandonGuided(_ canvas: AuxCanvasStrata, at date: Date) -> FoldResult {
        var next = canvas
        next.phase = .idle
        next.pendingPace = nil
        next.guided = nil
        let mark = AbandonMark(dayKey: canvas.dayKey, createdAt: date, leftPhase: .guided)
        return FoldResult(canvas: next, abandon: mark)
    }
}
