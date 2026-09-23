import AuxCanvasCore
import XCTest

final class PhaseFoldTests: XCTestCase {
    private let day = DayKey(raw: 20_260_920)
    private let now = Date(timeIntervalSince1970: 1_747_440_000)

    func test_pressFoldsIdleToPacing() {
        let canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        let result = CanvasFold.apply(.press(holdMillis: 900), to: canvas, at: now)
        XCTAssertNil(result.refusal)
        XCTAssertEqual(result.canvas.phase, .pacing)
        XCTAssertEqual(result.canvas.pendingPace?.millis, 900)
    }

    func test_swipeOnIdleIsRefused() {
        let canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        let result = CanvasFold.apply(.swipe(durationSeconds: 120), to: canvas, at: now)
        XCTAssertEqual(result.refusal, .swipeOnIdle)
        XCTAssertEqual(result.canvas.phase, .idle)
    }

    func test_secondPressWhileGuidedIsRefused() {
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        canvas = CanvasFold.apply(.press(holdMillis: 600), to: canvas, at: now).canvas
        canvas = CanvasFold.apply(.swipe(durationSeconds: 60), to: canvas, at: now).canvas
        XCTAssertEqual(canvas.phase, .guided)
        let result = CanvasFold.apply(.press(holdMillis: 800), to: canvas, at: now)
        XCTAssertEqual(result.refusal, .pressWhileGuided)
        XCTAssertEqual(result.canvas.phase, .guided)
        XCTAssertEqual(result.canvas.rings.count, 1)
    }

    func test_abandonMidCycleWritesAbandonMarkWithoutALayer() {
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        canvas = CanvasFold.apply(.press(holdMillis: 600), to: canvas, at: now).canvas
        canvas = CanvasFold.apply(.swipe(durationSeconds: 180), to: canvas, at: now).canvas
        let result = CanvasFold.apply(.abandon, to: canvas, at: now)
        XCTAssertNil(result.refusal)
        XCTAssertEqual(result.canvas.phase, .idle)
        XCTAssertEqual(result.canvas.rings.count, 1)
        XCTAssertNil(result.writtenLayer)
        XCTAssertEqual(result.abandon?.leftPhase, .guided)
        XCTAssertEqual(result.abandon?.dayKey, day)
    }

    func test_emptyCanvasWritesClear() {
        let canvas = AuxCanvasStrata.empty(dayKey: day)
        XCTAssertEqual(canvas.asClear?.dayKey, day)
        XCTAssertTrue(canvas.isClear)
    }
}
