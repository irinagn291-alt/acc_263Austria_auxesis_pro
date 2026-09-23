import AuxCanvasCore
import XCTest

/// Family breath_canvas invariant:
/// Long-press 0.6s starts; vertical drag sets 1…10 min; tap ends.
/// Phase scale 0.55→1 inhale, hold, 1→0.55 exhale.
/// Patterns: Calm 4-2-6, Box 4-4-4, 4-7-8.
final class FamilyInvariantTests: XCTestCase {
    private let day = DayKey(raw: 20_260_920)
    private let now = Date(timeIntervalSince1970: 1_747_440_000)

    func test_longPressPointSixSecondsStarts() {
        let canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        XCTAssertEqual(PaceHold.minimumPressMillis, 600)
        let short = CanvasFold.apply(.press(holdMillis: 599), to: canvas, at: now)
        XCTAssertEqual(short.refusal, .pressTooShort)
        XCTAssertEqual(short.canvas.phase, .idle)
        let started = CanvasFold.apply(.press(holdMillis: 600), to: canvas, at: now)
        XCTAssertNil(started.refusal)
        XCTAssertEqual(started.canvas.phase, .pacing)
        XCTAssertEqual(started.canvas.pendingPace?.millis, 600)
    }

    func test_verticalDragSetsOneToTenMinutes() {
        XCTAssertEqual(RoundDuration.minimumMinutes, 1)
        XCTAssertEqual(RoundDuration.maximumMinutes, 10)
        XCTAssertEqual(DragSpan.minutes(upwardPoints: 0), 1)
        XCTAssertEqual(DragSpan.minutes(upwardPoints: DragSpan.fullTravelPoints), 10)
        XCTAssertNil(RoundDuration(minutes: 0))
        XCTAssertNil(RoundDuration(minutes: 11))
        XCTAssertEqual(RoundDuration(minutes: 1)?.seconds, 60)
        XCTAssertEqual(RoundDuration(minutes: 10)?.seconds, 600)
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        canvas = CanvasFold.apply(.press(holdMillis: 600), to: canvas, at: now).canvas
        let span = DragSpan.seconds(upwardPoints: DragSpan.fullTravelPoints)
        let guided = CanvasFold.apply(.swipe(durationSeconds: span), to: canvas, at: now)
        XCTAssertNil(guided.refusal)
        XCTAssertEqual(guided.canvas.guided?.duration.minutes, 10)
    }

    func test_tapEndsGuidedWithoutALayer() {
        var canvas = AuxCanvasStrata.seeded(dayKey: day, at: now)
        canvas = CanvasFold.apply(.press(holdMillis: 600), to: canvas, at: now).canvas
        canvas = CanvasFold.apply(.swipe(durationSeconds: 120), to: canvas, at: now).canvas
        let ended = CanvasFold.apply(.abandon, to: canvas, at: now)
        XCTAssertEqual(ended.canvas.phase, .idle)
        XCTAssertEqual(ended.canvas.rings.count, 1)
        XCTAssertNotNil(ended.abandon)
    }

    func test_phaseScaleInhaleHoldExhale() {
        XCTAssertEqual(GuidedPhase.inhale.scaleFrom, 0.55)
        XCTAssertEqual(GuidedPhase.inhale.scaleTo, 1)
        XCTAssertEqual(GuidedPhase.hold.scaleFrom, 1)
        XCTAssertEqual(GuidedPhase.hold.scaleTo, 1)
        XCTAssertEqual(GuidedPhase.exhale.scaleFrom, 1)
        XCTAssertEqual(GuidedPhase.exhale.scaleTo, 0.55)
    }

    func test_calmBoxAndFourSevenEightPatterns() {
        XCTAssertEqual(BreathPattern.calm.inhaleBeats, 4)
        XCTAssertEqual(BreathPattern.calm.holdBeats, 2)
        XCTAssertEqual(BreathPattern.calm.exhaleBeats, 6)
        XCTAssertEqual(BreathPattern.box.inhaleBeats, 4)
        XCTAssertEqual(BreathPattern.box.holdBeats, 4)
        XCTAssertEqual(BreathPattern.box.exhaleBeats, 4)
        XCTAssertEqual(BreathPattern.fourSevenEight.inhaleBeats, 4)
        XCTAssertEqual(BreathPattern.fourSevenEight.holdBeats, 7)
        XCTAssertEqual(BreathPattern.fourSevenEight.exhaleBeats, 8)
        XCTAssertEqual(BreathPattern.catalog.count, 3)
    }

    func test_dayKeyUsesStartOfDayNotStringFormatting() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let morning = calendar.date(from: DateComponents(year: 2025, month: 5, day: 16, hour: 1))
        let evening = calendar.date(from: DateComponents(year: 2025, month: 5, day: 16, hour: 23))
        XCTAssertNotNil(morning)
        XCTAssertNotNil(evening)
        guard let morning, let evening else { return }
        XCTAssertEqual(DayKey.of(morning, calendar: calendar), DayKey.of(evening, calendar: calendar))
        XCTAssertEqual(
            calendar.startOfDay(for: morning),
            DayKey.of(morning, calendar: calendar).startDate(calendar: calendar)
        )
        XCTAssertEqual(DayKey.of(morning, calendar: calendar).raw, 20_250_516)
    }
}
