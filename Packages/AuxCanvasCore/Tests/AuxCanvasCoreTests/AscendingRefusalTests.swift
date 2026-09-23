import AuxCanvasCore
import XCTest

final class AscendingRefusalTests: XCTestCase {
    private let day = DayKey(raw: 20_260_920)
    private let now = Date(timeIntervalSince1970: 1_747_440_000)

    func test_shortSwipeIsRefusedAndNamesTheFloor() {
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        canvas = CanvasFold.apply(.press(holdMillis: 600), to: canvas, at: now).canvas
        let result = CanvasFold.apply(.swipe(durationSeconds: 59), to: canvas, at: now)
        XCTAssertEqual(result.refusal, .durationOutOfRange)
        XCTAssertEqual(result.canvas.phase, .pacing)
        XCTAssertEqual(result.canvas.rings.count, 1)
    }

    func test_swipeShorterThanOutermostIsRefused() {
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        canvas = completeRound(on: canvas, seconds: 180)
        canvas = CanvasFold.apply(.press(holdMillis: 800), to: canvas, at: now).canvas
        let result = CanvasFold.apply(.swipe(durationSeconds: 120), to: canvas, at: now)
        XCTAssertEqual(result.refusal, .durationBelowFloor(floorSeconds: 180))
        XCTAssertEqual(result.canvas.phase, .pacing)
        XCTAssertEqual(result.canvas.rings.count, 2)
        XCTAssertNil(result.writtenLayer)
    }

    func test_equalOrLongerSwipeIsAccepted() {
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        canvas = CanvasFold.apply(.press(holdMillis: 600), to: canvas, at: now).canvas
        let equal = CanvasFold.apply(.swipe(durationSeconds: 60), to: canvas, at: now)
        XCTAssertNil(equal.refusal)
        XCTAssertEqual(equal.canvas.phase, .guided)
        canvas = equal.canvas
        canvas = CanvasFold.apply(.completeExhale, to: canvas, at: now).canvas
        canvas = CanvasFold.apply(.press(holdMillis: 600), to: canvas, at: now).canvas
        let longer = CanvasFold.apply(.swipe(durationSeconds: 120), to: canvas, at: now)
        XCTAssertNil(longer.refusal)
        XCTAssertEqual(longer.canvas.guided?.duration.seconds, 120)
    }

    func test_emptyPopulatedAndInvalidPrimaryVerb() {
        let empty = AuxCanvasStrata.empty(dayKey: day)
        XCTAssertTrue(empty.isClear)
        XCTAssertEqual(CanvasFold.apply(.swipe(durationSeconds: 60), to: empty, at: now).refusal, .swipeOnIdle)

        var seeded = AuxCanvasStrata.seeded(dayKey: day, at: now)
        XCTAssertFalse(seeded.isClear)
        XCTAssertEqual(seeded.rings.count, 1)
        let started = CanvasFold.apply(.press(holdMillis: 600), to: seeded, at: now)
        XCTAssertNil(started.refusal)
        XCTAssertEqual(started.canvas.phase, .pacing)

        seeded = started.canvas
        let invalid = CanvasFold.apply(.swipe(durationSeconds: 900), to: seeded, at: now)
        XCTAssertEqual(invalid.refusal, .durationOutOfRange)
    }

    private func completeRound(on canvas: AuxCanvasStrata, seconds: Int) -> AuxCanvasStrata {
        var next = CanvasFold.apply(.press(holdMillis: 700), to: canvas, at: now).canvas
        next = CanvasFold.apply(.swipe(durationSeconds: seconds), to: next, at: now).canvas
        return CanvasFold.apply(.completeExhale, to: next, at: now).canvas
    }
}
