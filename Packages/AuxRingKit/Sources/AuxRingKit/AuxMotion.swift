import UIKit

/// Role: quiet motion. Cross-fade 180ms ease-out. Reduce Motion stays instant.
@MainActor
public enum AuxMotion {
    public static let fade: TimeInterval = 0.18

    public static var shouldTravel: Bool {
        !UIAccessibility.isReduceMotionEnabled
    }

    public static func animate(_ changes: @escaping () -> Void, completion: (() -> Void)? = nil) {
        if shouldTravel {
            UIView.animate(
                withDuration: fade,
                delay: 0,
                options: [.curveEaseOut, .beginFromCurrentState],
                animations: changes,
                completion: { _ in completion?() }
            )
        } else {
            changes()
            completion?()
        }
    }
}
