import AuxCanvasCore
import XCTest

final class FullMarkSealTests: XCTestCase {
    private let day = DayKey(raw: 20_260_920)
    private let now = Date(timeIntervalSince1970: 1_747_440_000)

    func test_seventhLayerSealsTheCanvas() {
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        for index in 1 ..< (FullMarkSeal.ringCapacity - 1) {
            canvas = completeRound(on: canvas, seconds: 60 + index * 30)
            XCTAssertFalse(canvas.isSealed, "seal arrives on the seventh ring")
        }
        XCTAssertEqual(canvas.rings.count, 6)
        let last = finishRound(on: canvas, seconds: 300)
        XCTAssertNil(last.refusal)
        XCTAssertEqual(last.canvas.rings.count, 7)
        XCTAssertTrue(last.canvas.isSealed)
        XCTAssertEqual(last.fullMark?.dayKey, day)
        XCTAssertTrue(FullMarkSeal.shouldSeal(ringCount: last.canvas.rings.count))
    }

    func test_foldRefusesEveryEventOnASealedCanvas() {
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        for index in 1 ... 6 {
            canvas = completeRound(on: canvas, seconds: 60 + index * 20)
        }
        XCTAssertTrue(canvas.isSealed)
        XCTAssertEqual(CanvasFold.apply(.press(holdMillis: 800), to: canvas, at: now).refusal, .canvasSealed)
        XCTAssertEqual(CanvasFold.apply(.swipe(durationSeconds: 300), to: canvas, at: now).refusal, .canvasSealed)
        XCTAssertEqual(CanvasFold.apply(.completeExhale, to: canvas, at: now).refusal, .canvasSealed)
        XCTAssertEqual(CanvasFold.apply(.abandon, to: canvas, at: now).refusal, .canvasSealed)
        XCTAssertEqual(canvas.rings.count, 7)
    }

    private func completeRound(on canvas: AuxCanvasStrata, seconds: Int) -> AuxCanvasStrata {
        finishRound(on: canvas, seconds: seconds).canvas
    }

    private func finishRound(on canvas: AuxCanvasStrata, seconds: Int) -> FoldResult {
        var next = CanvasFold.apply(.press(holdMillis: 700), to: canvas, at: now).canvas
        next = CanvasFold.apply(.swipe(durationSeconds: seconds), to: next, at: now).canvas
        return CanvasFold.apply(.completeExhale, to: next, at: now)
    }
}
