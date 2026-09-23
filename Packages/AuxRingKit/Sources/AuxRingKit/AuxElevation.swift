import UIKit

/// Role: the only elevation language. Hairline plus fill. No second shadow kit.
@MainActor
public enum AuxElevation {
    public static var borderWidth: CGFloat { 1 }

    public static func apply(
        to view: UIView,
        fill: UIColor = AuxColor.surface,
        radius: CGFloat = AuxRadius.surface
    ) {
        view.backgroundColor = fill
        view.layer.cornerRadius = radius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = AuxColor.muted.withAlphaComponent(0.35).cgColor
        view.layer.masksToBounds = true
    }
}
