import AuxCanvasCore
import AuxCanvasStore
import XCTest

final class SealPersistenceTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: 20, hour: 15))
            ?? Date(timeIntervalSince1970: 1_790_000_000)
    }

    private var day: DayKey {
        DayKey.of(now, calendar: calendar)
    }

    func test_writeReloadAndSealedWriteThrows() async throws {
        let store = try await AuxStore.open(inMemory: true)
        var canvas = try await store.seedIfNeeded(dayKey: day, at: now)
        XCTAssertEqual(canvas.rings.count, 1)
        XCTAssertTrue(canvas.rings[0].isSeed)

        for index in 1 ... 6 {
            canvas = try await finishRound(in: store, seconds: 60 + index * 20)
        }
        XCTAssertTrue(canvas.isSealed)
        XCTAssertEqual(canvas.rings.count, 7)

        let reloaded = try await AuxStore.open(inMemory: true)
        let empty = try await reloaded.canvas(for: day)
        XCTAssertTrue(empty.isClear)

        let same = try await store.canvas(for: day)
        XCTAssertTrue(same.isSealed)
        XCTAssertEqual(same.rings.count, 7)
        XCTAssertEqual(same.rings.last?.duration.seconds, 180)

        do {
            _ = try await store.apply(.completeExhale, on: day, at: now)
            XCTFail("a write to a sealed canvas throws")
        } catch let error as AuxStoreError {
            XCTAssertEqual(error, .canvasSealed)
        }

        let stats = try await store.stats(now: now, calendar: calendar)
        XCTAssertEqual(stats.fullMarkCount, 1)
        XCTAssertEqual(stats.ringLayerCount, 7)
        XCTAssertEqual(stats.longestRingSeconds, 180)
        XCTAssertEqual(stats.consecutiveDayStreak, 1)
    }

    func test_resetClearsPersistedStrata() async throws {
        let store = try await AuxStore.open(inMemory: true)
        _ = try await store.seedIfNeeded(dayKey: day, at: now)
        _ = try await finishRound(in: store, seconds: 90)
        try await store.resetAllData()
        let cleared = try await store.canvas(for: day)
        XCTAssertTrue(cleared.isClear)
        let practices = try await store.practices()
        XCTAssertTrue(practices.isEmpty)
    }

    func test_abandonDoesNotPersistARing() async throws {
        let store = try await AuxStore.open(inMemory: true)
        _ = try await store.seedIfNeeded(dayKey: day, at: now)
        _ = try await store.apply(.press(holdMillis: 700), on: day, at: now)
        _ = try await store.apply(.swipe(durationSeconds: 120), on: day, at: now)
        let abandoned = try await store.apply(.abandon, on: day, at: now)
        XCTAssertEqual(abandoned.canvas.rings.count, 1)
        XCTAssertNotNil(abandoned.abandon)
        let stored = try await store.canvas(for: day)
        XCTAssertEqual(stored.rings.count, 1)
        XCTAssertTrue(stored.rings[0].isSeed)
    }

    private func finishRound(in store: AuxStore, seconds: Int) async throws -> AuxCanvasStrata {
        _ = try await store.apply(.press(holdMillis: 700), on: day, at: now)
        _ = try await store.apply(.swipe(durationSeconds: seconds), on: day, at: now)
        return try await store.apply(.completeExhale, on: day, at: now).canvas
    }
}
