import AuxCanvasCore
import Foundation

/// Role: visible refusal lines. Color is never the only signal.
enum RefusalCopy {
    static func line(for refusal: CanvasRefusal) -> String {
        switch refusal {
        case .swipeOnIdle:
            return "Long press first. The swipe waits."
        case .pressWhileGuided:
            return "This round is already underway."
        case .pressTooShort:
            return "Hold a little longer to set the pace."
        case .durationOutOfRange:
            return "The span stays between one and ten minutes."
        case .durationBelowFloor(let floorSeconds):
            return "Each ring must last at least \(AuxFormat.minutes(floorSeconds))."
        case .canvasSealed:
            return "Today is sealed. Seven rings are complete."
        case .notGuided:
            return "Finish the swipe before the cycle can close."
        case .alreadyGuided:
            return "This round is already underway."
        }
    }
}
