import AuxRingKit
import UIKit

/// Role: names a fold refusal in copy so color is never the only signal.
@MainActor
final class RefusalBanner: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        AuxElevation.apply(to: self)
        isHidden = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AuxType.caption()
        label.textColor = AuxColor.ink
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        addSubview(label)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AuxSpace.step(2)),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AuxSpace.step(2)),
            label.topAnchor.constraint(equalTo: topAnchor, constant: AuxSpace.step(1)),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AuxSpace.step(1)),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This banner is built in code.")
    }

    func show(_ text: String) {
        label.text = text
        isHidden = false
        alpha = 0
        AuxMotion.animate { self.alpha = 1 }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hide), object: nil)
        perform(#selector(hide), with: nil, afterDelay: 2.4)
    }

    @objc private func hide() {
        AuxMotion.animate { self.alpha = 0 } completion: {
            self.isHidden = true
        }
    }
}
