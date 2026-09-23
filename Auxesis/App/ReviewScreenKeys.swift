import Foundation

/// Role: parses `-ReviewScreen` once after onboarding. Keys are launch arguments, not tabs.
enum ReviewScreenKey: String, Equatable, Sendable {
    case today
    case log
    case goals
    case settings
    case strata
}

enum ReviewScreenKeys {
    static func current(from info: ProcessInfo = .processInfo) -> ReviewScreenKey? {
        parse(arguments: info.arguments)
    }

    static func parse(arguments: [String]) -> ReviewScreenKey? {
        guard let index = arguments.firstIndex(of: "-ReviewScreen") else { return nil }
        let next = index + 1
        guard next < arguments.count else { return nil }
        return ReviewScreenKey(rawValue: arguments[next])
    }
}
