import Foundation

/// Role: versioned UserDefaults keys. Simulator seed and onboarding share this table.
enum AuxPreferences {
    static let onboardingComplete = "aux.onboarding.complete.v1"
    static let demo = "aux.demo.v1"
    static let haptics = "aux.haptics.intensity.v1"

    static var isOnboardingComplete: Bool {
        UserDefaults.standard.bool(forKey: onboardingComplete)
    }

    static func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: onboardingComplete)
    }

    static func clearOnboarding() {
        UserDefaults.standard.set(false, forKey: onboardingComplete)
    }

    static var hapticStyle: HapticIntensity {
        guard UserDefaults.standard.object(forKey: haptics) != nil else { return .medium }
        return HapticIntensity(rawValue: UserDefaults.standard.integer(forKey: haptics)) ?? .medium
    }

    static func setHapticStyle(_ value: HapticIntensity) {
        UserDefaults.standard.set(value.rawValue, forKey: haptics)
    }
}

enum HapticIntensity: Int, CaseIterable, Sendable {
    case off = 0
    case light = 1
    case medium = 2
    case heavy = 3

    var title: String {
        switch self {
        case .off: "Off"
        case .light: "Soft"
        case .medium: "Even"
        case .heavy: "Firm"
        }
    }
}
