import UIKit

/// Role: soft-card control. The whole pill is the button. Labels sit inside it.
public final class AuxButton: UIButton {
    public enum Kind {
        case primary
        case secondary
        case destructive
        case chrome
    }

    public let kind: Kind

    public init(title: String, kind: Kind) {
        self.kind = kind
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = fillColor
        config.baseForegroundColor = inkColor
        config.cornerStyle = .fixed
        config.background.cornerRadius = AuxRadius.surface
        config.background.strokeColor = AuxColor.muted.withAlphaComponent(0.35)
        config.background.strokeWidth = AuxElevation.borderWidth
        config.contentInsets = NSDirectionalEdgeInsets(
            top: AuxSpace.step(2),
            leading: AuxSpace.step(2),
            bottom: AuxSpace.step(2),
            trailing: AuxSpace.step(2)
        )
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AuxType.body()
            return outgoing
        }
        configuration = config
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.8
        accessibilityLabel = title
        configurationUpdateHandler = { [weak self] button in
            self?.applyChrome(to: button)
        }
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
        ])
    }

    public func setTitleText(_ title: String) {
        var config = configuration ?? .filled()
        config.title = title
        configuration = config
        accessibilityLabel = title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This control is built in code.")
    }

    private var fillColor: UIColor {
        switch kind {
        case .primary: AuxColor.accent
        case .secondary, .chrome, .destructive: AuxColor.surface
        }
    }

    private var inkColor: UIColor {
        switch kind {
        case .primary: AuxColor.background
        case .secondary, .chrome: AuxColor.ink
        case .destructive: AuxColor.ink
        }
    }

    private func applyChrome(to button: UIButton) {
        var config = button.configuration ?? .filled()
        config.baseBackgroundColor = fillColor
        config.baseForegroundColor = inkColor
        button.configuration = config
        if !button.isEnabled {
            button.alpha = 0.4
            button.transform = .identity
        } else if button.isHighlighted {
            button.alpha = 0.72
            if AuxMotion.shouldTravel {
                button.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            }
        } else {
            button.alpha = 1
            button.transform = .identity
        }
    }
}
