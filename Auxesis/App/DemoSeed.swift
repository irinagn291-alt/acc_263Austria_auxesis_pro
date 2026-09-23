import AuxCanvasCore
import AuxCanvasStore
import Foundation

/// Role: Simulator-only happy path. Marks onboarding complete so review keys can fire.
enum DemoSeed {
    static func applyIfNeeded(store: AuxStore) async throws {
        #if targetEnvironment(simulator)
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: AuxPreferences.demo) == false else {
            AuxPreferences.markOnboardingComplete()
            return
        }
        try await plant(store: store)
        defaults.set(true, forKey: AuxPreferences.demo)
        AuxPreferences.markOnboardingComplete()
        if defaults.object(forKey: AuxPreferences.haptics) == nil {
            AuxPreferences.setHapticStyle(.medium)
        }
        #endif
    }

    #if targetEnvironment(simulator)
    private static func plant(store: AuxStore) async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        try await fill(store: store, day: offset(-5, from: today, calendar: calendar), added: 6)
        try await fill(store: store, day: offset(-3, from: today, calendar: calendar), added: 3)
        try await fill(store: store, day: offset(-2, from: today, calendar: calendar), added: 6)
        try await fill(store: store, day: offset(-1, from: today, calendar: calendar), added: 4)
        try await fill(store: store, day: today, added: 2)
    }

    private static func offset(_ days: Int, from today: Date, calendar: Calendar) -> Date {
        calendar.date(byAdding: .day, value: days, to: today) ?? today
    }

    private static func fill(store: AuxStore, day: Date, added: Int) async throws {
        let dayKey = DayKey.of(day)
        _ = try await store.seedIfNeeded(dayKey: dayKey, at: day)
        var minutes = 2
        for _ in 0 ..< added {
            _ = try await store.apply(.press(holdMillis: 900), on: dayKey, at: day)
            _ = try await store.apply(.swipe(durationSeconds: minutes * 60), on: dayKey, at: day)
            _ = try await store.apply(.completeExhale, on: dayKey, at: day)
            minutes = min(RoundDuration.maximumMinutes, minutes + 1)
        }
    }
    #endif
}
