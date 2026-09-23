import AuxRingKit
import UIKit

/// Role: title at the leading margin, a fixed close chip at the trailing edge.
@MainActor
final class SheetHeaderView: UIView {
    let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = AuxType.sectionTitle()
        titleLabel.textColor = AuxColor.ink
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = AuxColor.ink
        closeButton.accessibilityLabel = "Close"
        closeButton.setContentHuggingPriority(.required, for: .horizontal)
        closeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        AuxElevation.apply(to: closeButton, radius: AuxRadius.surface)

        addSubview(titleLabel)
        addSubview(closeButton)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.step(7)),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: closeButton.leadingAnchor, constant: -AuxSpace.step(1)),

            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: AuxSpace.hit),
            closeButton.heightAnchor.constraint(equalToConstant: AuxSpace.hit),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This header is built in code.")
    }
}
