import AuxRingKit
import UIKit

/// Role: caption, value, unit on one tappable plate. The whole card is the button.
@MainActor
final class FactTileButton: UIButton {
    private let keyLabel = UILabel()
    private let valueLabel = UILabel()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        AuxElevation.apply(to: self)

        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.adjustsFontForContentSizeCategory = true
        keyLabel.isUserInteractionEnabled = false

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = AuxType.canvasFigure(compatibleWith: traitCollection)
        valueLabel.textColor = AuxColor.ink
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        valueLabel.isUserInteractionEnabled = false

        addSubview(keyLabel)
        addSubview(valueLabel)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
            keyLabel.topAnchor.constraint(equalTo: topAnchor, constant: AuxSpace.step(2)),
            keyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AuxSpace.step(2)),
            keyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AuxSpace.step(2)),
            valueLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: AuxSpace.unit),
            valueLabel.leadingAnchor.constraint(equalTo: keyLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: keyLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AuxSpace.step(2)),
        ])
        configurationUpdateHandler = { [weak self] button in
            self?.alpha = button.isHighlighted ? 0.72 : 1
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This fact tile is built in code.")
    }

    func apply(key: String, value: String) {
        keyLabel.attributedText = AuxType.hairlineAttributed(key, color: AuxColor.muted)
        valueLabel.text = value
        accessibilityLabel = "\(key), \(value)"
    }

    func refreshFigureFont(compatibleWith traits: UITraitCollection) {
        valueLabel.font = AuxType.canvasFigure(compatibleWith: traits)
    }
}
