import UIKit

/// Role: full-page empty. Art, one headline, one line, one bottom-width CTA.
public final class AuxEmptyState: UIView {
    public let actionButton: AuxButton

    private let artView = UIImageView()
    private let headline = UILabel()
    private let line = UILabel()

    public init(image: UIImage?, headlineText: String, lineText: String, actionTitle: String) {
        actionButton = AuxButton(title: actionTitle, kind: .primary)
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AuxColor.background

        artView.translatesAutoresizingMaskIntoConstraints = false
        artView.contentMode = .scaleAspectFit
        artView.image = image
        artView.isAccessibilityElement = false
        if image == nil {
            AuxElevation.apply(to: artView, radius: AuxRadius.surface)
        }

        headline.translatesAutoresizingMaskIntoConstraints = false
        headline.text = headlineText
        headline.font = AuxType.sectionTitle()
        headline.textColor = AuxColor.ink
        headline.numberOfLines = 2
        headline.adjustsFontForContentSizeCategory = true
        headline.textAlignment = .left

        line.translatesAutoresizingMaskIntoConstraints = false
        line.text = lineText
        line.font = AuxType.body()
        line.textColor = AuxColor.muted
        line.numberOfLines = 0
        line.adjustsFontForContentSizeCategory = true
        line.textAlignment = .left

        addSubview(artView)
        addSubview(headline)
        addSubview(line)
        addSubview(actionButton)

        let artHeight: NSLayoutConstraint
        if image == nil {
            artHeight = artView.heightAnchor.constraint(equalToConstant: AuxSpace.step(12))
        } else {
            artHeight = artView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.42)
        }

        NSLayoutConstraint.activate([
            artView.topAnchor.constraint(equalTo: topAnchor, constant: AuxSpace.step(3)),
            artView.leadingAnchor.constraint(equalTo: leadingAnchor),
            artView.trailingAnchor.constraint(equalTo: trailingAnchor),
            artHeight,

            headline.topAnchor.constraint(equalTo: artView.bottomAnchor, constant: AuxSpace.step(3)),
            headline.leadingAnchor.constraint(equalTo: leadingAnchor),
            headline.trailingAnchor.constraint(equalTo: trailingAnchor),

            line.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: AuxSpace.step(1)),
            line.leadingAnchor.constraint(equalTo: leadingAnchor),
            line.trailingAnchor.constraint(equalTo: trailingAnchor),

            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This surface is built in code.")
    }
}
