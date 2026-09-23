import AuxRingKit
import UIKit

/// Role: one first-launch page. Continue writes defaults. Re-runnable from Settings.
@MainActor
final class OnboardingViewController: UIViewController {
    var onFinished: (() -> Void)?

    private let art = UIImageView()
    private let headline = UILabel()
    private let line = UILabel()
    private let continueButton = AuxButton(title: "Continue", kind: .primary)
    private var artHeight: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AuxColor.background
        build()
        render()
    }

    private func build() {
        art.translatesAutoresizingMaskIntoConstraints = false
        art.contentMode = .scaleAspectFit
        art.isAccessibilityElement = false

        headline.translatesAutoresizingMaskIntoConstraints = false
        headline.font = AuxType.sectionTitle()
        headline.textColor = AuxColor.ink
        headline.numberOfLines = 2
        headline.adjustsFontForContentSizeCategory = true

        line.translatesAutoresizingMaskIntoConstraints = false
        line.font = AuxType.body()
        line.textColor = AuxColor.muted
        line.numberOfLines = 2
        line.adjustsFontForContentSizeCategory = true

        continueButton.addTarget(self, action: #selector(finish), for: .touchUpInside)

        view.addSubview(art)
        view.addSubview(headline)
        view.addSubview(line)
        view.addSubview(continueButton)

        let guide = view.safeAreaLayoutGuide
        let height = art.heightAnchor.constraint(equalToConstant: AuxSpace.step(16))
        artHeight = height
        NSLayoutConstraint.activate([
            art.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(2)),
            art.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            art.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),
            height,

            headline.topAnchor.constraint(equalTo: art.bottomAnchor, constant: AuxSpace.step(3)),
            headline.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            headline.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),

            line.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: AuxSpace.step(1)),
            line.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: headline.trailingAnchor),

            continueButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            continueButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),
            continueButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -AuxSpace.step(2)),
        ])
    }

    private func render() {
        art.image = AuxAsset.image(AuxAsset.onboarding1)
        if art.image == nil {
            AuxElevation.apply(to: art)
            artHeight?.constant = AuxSpace.step(12)
        } else {
            artHeight?.constant = AuxSpace.step(28)
        }
        headline.text = "Breathe longer each round."
        line.text = "Hold the circle, then swipe a span so today's rings can grow."
    }

    @objc private func finish() {
        if UserDefaults.standard.object(forKey: AuxPreferences.haptics) == nil {
            AuxPreferences.setHapticStyle(.medium)
        }
        AuxPreferences.markOnboardingComplete()
        onFinished?()
    }
}
