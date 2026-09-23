import Foundation

/// Role: inhale-hold-exhale beat counts. Calm 4-2-6, Box 4-4-4, 4-7-8.
public struct BreathPattern: Hashable, Sendable, Codable {
    public let inhaleBeats: Int
    public let holdBeats: Int
    public let exhaleBeats: Int

    public init(inhaleBeats: Int, holdBeats: Int, exhaleBeats: Int) {
        self.inhaleBeats = inhaleBeats
        self.holdBeats = holdBeats
        self.exhaleBeats = exhaleBeats
    }

    public static let calm = BreathPattern(inhaleBeats: 4, holdBeats: 2, exhaleBeats: 6)
    public static let box = BreathPattern(inhaleBeats: 4, holdBeats: 4, exhaleBeats: 4)
    public static let fourSevenEight = BreathPattern(inhaleBeats: 4, holdBeats: 7, exhaleBeats: 8)

    public static let catalog: [BreathPattern] = [.calm, .box, .fourSevenEight]
}
