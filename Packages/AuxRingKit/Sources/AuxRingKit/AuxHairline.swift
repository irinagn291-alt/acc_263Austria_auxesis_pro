import UIKit

/// Role: 0.5pt rules that separate tiles and rows.
public final class AuxHairline: UIView {
    public init(color: UIColor = AuxColor.muted) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = color.withAlphaComponent(0.45)
        isAccessibilityElement = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: AuxSpace.hairline),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This control is built in code.")
    }
}
