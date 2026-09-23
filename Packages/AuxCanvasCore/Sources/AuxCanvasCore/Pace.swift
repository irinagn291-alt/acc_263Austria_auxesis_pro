import Foundation

/// Role: PaceHold. The held haptic interval captured during Pacing, in milliseconds.
public struct PaceHold: Hashable, Sendable, Codable {
    public static let minimumPressMillis = 600

    public let millis: Int

    public init(millis: Int) {
        self.millis = millis
    }

    public static func fromHold(_ millis: Int) -> PaceHold? {
        guard millis >= minimumPressMillis else { return nil }
        return PaceHold(millis: millis)
    }
}
