import AuxCanvasCore
import AuxRingKit
import UIKit

/// Role: the twist screen. Ascending-ring strata, plus the floor already shown on Canvas.
@MainActor
final class StrataSheetViewController: UIViewController {
    private let canvas: AuxCanvasStrata?
    private let header = SheetHeaderView(title: "Ascending rings")
    private let art = UIImageView()
    private let headline = UILabel()
    private let line = UILabel()
    private let floor = UILabel()
    private let seal = UILabel()

    init(canvas: AuxCanvasStrata?) {
        self.canvas = canvas
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This sheet is built in code.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AuxColor.background
        header.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        art.translatesAutoresizingMaskIntoConstraints = false
        art.contentMode = .scaleAspectFit
        art.image = AuxAsset.image(AuxAsset.twistHero)
        art.isAccessibilityElement = false
        if art.image == nil {
            AuxElevation.apply(to: art)
        }

        headline.translatesAutoresizingMaskIntoConstraints = false
        headline.text = "Rings only grow."
        headline.font = AuxType.sectionTitle()
        headline.textColor = AuxColor.ink
        headline.numberOfLines = 2
        headline.adjustsFontForContentSizeCategory = true

        line.translatesAutoresizingMaskIntoConstraints = false
        line.text = "Each swipe must last as long as the ring outside it. A shorter span is refused before the cycle starts."
        line.font = AuxType.body()
        line.textColor = AuxColor.muted
        line.numberOfLines = 0
        line.adjustsFontForContentSizeCategory = true

        let seconds = canvas?.outermostDuration?.seconds ?? RoundDuration.minimumSeconds
        floor.translatesAutoresizingMaskIntoConstraints = false
        floor.font = AuxType.body()
        floor.textColor = AuxColor.ink
        floor.numberOfLines = 0
        floor.adjustsFontForContentSizeCategory = true
        floor.text = "Today's floor is \(AuxFormat.minutes(seconds))."

        seal.translatesAutoresizingMaskIntoConstraints = false
        seal.font = AuxType.body()
        seal.textColor = AuxColor.ink
        seal.numberOfLines = 0
        seal.adjustsFontForContentSizeCategory = true
        seal.text = canvas?.isSealed == true
            ? "This day is sealed. Seven rings hold the canvas."
            : "Seven rings seal the day."

        let floorTile = AuxTile()
        let sealTile = AuxTile()
        floor.translatesAutoresizingMaskIntoConstraints = false
        seal.translatesAutoresizingMaskIntoConstraints = false
        floorTile.addSubview(floor)
        sealTile.addSubview(seal)

        view.addSubview(header)
        view.addSubview(art)
        view.addSubview(headline)
        view.addSubview(line)
        view.addSubview(floorTile)
        view.addSubview(sealTile)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(1)),
            header.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            header.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),

            art.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AuxSpace.step(2)),
            art.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            art.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),
            art.heightAnchor.constraint(equalToConstant: AuxSpace.step(14)),

            headline.topAnchor.constraint(equalTo: art.bottomAnchor, constant: AuxSpace.step(2)),
            headline.leadingAnchor.constraint(equalTo: art.leadingAnchor),
            headline.trailingAnchor.constraint(equalTo: art.trailingAnchor),

            line.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: AuxSpace.unit),
            line.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: headline.trailingAnchor),

            floorTile.topAnchor.constraint(equalTo: line.bottomAnchor, constant: AuxSpace.step(2)),
            floorTile.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            floorTile.trailingAnchor.constraint(equalTo: headline.trailingAnchor),

            floor.topAnchor.constraint(equalTo: floorTile.topAnchor, constant: AuxSpace.step(2)),
            floor.leadingAnchor.constraint(equalTo: floorTile.leadingAnchor, constant: AuxSpace.step(2)),
            floor.trailingAnchor.constraint(equalTo: floorTile.trailingAnchor, constant: -AuxSpace.step(2)),
            floor.bottomAnchor.constraint(equalTo: floorTile.bottomAnchor, constant: -AuxSpace.step(2)),

            sealTile.topAnchor.constraint(equalTo: floorTile.bottomAnchor, constant: AuxSpace.step(1)),
            sealTile.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            sealTile.trailingAnchor.constraint(equalTo: headline.trailingAnchor),

            seal.topAnchor.constraint(equalTo: sealTile.topAnchor, constant: AuxSpace.step(2)),
            seal.leadingAnchor.constraint(equalTo: sealTile.leadingAnchor, constant: AuxSpace.step(2)),
            seal.trailingAnchor.constraint(equalTo: sealTile.trailingAnchor, constant: -AuxSpace.step(2)),
            seal.bottomAnchor.constraint(equalTo: sealTile.bottomAnchor, constant: -AuxSpace.step(2)),
        ])
    }

    @objc private func close() {
        dismiss(animated: AuxMotion.shouldTravel)
    }
}
