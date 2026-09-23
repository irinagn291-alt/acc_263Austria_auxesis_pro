import Foundation

/// Role: the swiped round span. Vertical drag maps onto 1...10 minutes. Stored as seconds.
public struct RoundDuration: Hashable, Sendable, Comparable, Codable {
    public static let minimumMinutes = 1
    public static let maximumMinutes = 10
    public static let minimumSeconds = minimumMinutes * 60
    public static let maximumSeconds = maximumMinutes * 60

    public let seconds: Int

    public var minutes: Int { seconds / 60 }

    public init?(seconds: Int) {
        guard (Self.minimumSeconds ... Self.maximumSeconds).contains(seconds) else { return nil }
        self.seconds = seconds
    }

    public init?(minutes: Int) {
        self.init(seconds: minutes * 60)
    }

    /// Seed is the floor of the legal span. The bounds make this path unfailable.
    public static let thinSeed = RoundDuration(validSeconds: minimumSeconds)

    private init(validSeconds: Int) {
        seconds = validSeconds
    }

    public static func < (lhs: RoundDuration, rhs: RoundDuration) -> Bool {
        lhs.seconds < rhs.seconds
    }
}

/// Role: maps an upward drag onto the 1...10 minute swipe span before the fold sees seconds.
public enum DragSpan {
    public static let fullTravelPoints = 240.0

    public static func minutes(upwardPoints: Double, fullTravel: Double = fullTravelPoints) -> Int {
        guard fullTravel > 0 else { return RoundDuration.minimumMinutes }
        let progress = min(1, max(0, upwardPoints / fullTravel))
        let span = Double(RoundDuration.maximumMinutes - RoundDuration.minimumMinutes)
        return RoundDuration.minimumMinutes + Int((span * progress).rounded())
    }

    public static func seconds(upwardPoints: Double, fullTravel: Double = fullTravelPoints) -> Int {
        minutes(upwardPoints: upwardPoints, fullTravel: fullTravel) * 60
    }
}
