import AuxCanvasCore
import AuxRingKit
import UIKit

/// Role: an in-palette ring count plate. Never a stray raster disc.
@MainActor
final class RingCountMark: UIView {
    private let value = UILabel()
    private let caption = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        AuxElevation.apply(to: self, fill: AuxColor.accent, radius: AuxRadius.surface)

        value.translatesAutoresizingMaskIntoConstraints = false
        value.font = AuxType.sectionTitle()
        value.textColor = AuxColor.background
        value.textAlignment = .center
        value.adjustsFontForContentSizeCategory = true
        value.adjustsFontSizeToFitWidth = true
        value.minimumScaleFactor = 0.7

        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.font = AuxType.caption()
        caption.textColor = AuxColor.background
        caption.textAlignment = .center
        caption.adjustsFontForContentSizeCategory = true

        addSubview(value)
        addSubview(caption)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.step(12)),
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.step(12)),
            value.topAnchor.constraint(equalTo: topAnchor, constant: AuxSpace.step(1)),
            value.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AuxSpace.unit),
            value.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AuxSpace.unit),
            caption.topAnchor.constraint(equalTo: value.bottomAnchor),
            caption.leadingAnchor.constraint(equalTo: value.leadingAnchor),
            caption.trailingAnchor.constraint(equalTo: value.trailingAnchor),
            caption.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AuxSpace.step(1)),
        ])
        isAccessibilityElement = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This mark is built in code.")
    }

    func apply(count: Int, sealed: Bool) {
        value.text = AuxFormat.ringsOutOfSeven(count)
        caption.text = sealed ? "Sealed" : "Partial"
        accessibilityLabel = "\(caption.text ?? ""), \(value.text ?? "")"
    }
}

/// Role: seven ring slots as chips. Filled is a solid bar; empty is a hollow bar.
@MainActor
final class RingSlotColumn: UIStackView {
    static let markHeight: CGFloat = 4

    private var marks: [UIView] = []

    init(axis: NSLayoutConstraint.Axis = .vertical) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        self.axis = axis
        distribution = .fillEqually
        spacing = AuxSpace.unit
        isUserInteractionEnabled = false
        for _ in 0 ..< FullMarkSeal.ringCapacity {
            let mark = UIView()
            mark.translatesAutoresizingMaskIntoConstraints = false
            mark.layer.cornerRadius = AuxRadius.chip
            mark.layer.borderWidth = AuxElevation.borderWidth
            mark.heightAnchor.constraint(equalToConstant: Self.markHeight).isActive = true
            addArrangedSubview(mark)
            marks.append(mark)
        }
        if axis == .horizontal {
            heightAnchor.constraint(equalToConstant: Self.markHeight).isActive = true
        }
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) is unused. This slot column is built in code.")
    }

    func apply(filled: Int, vacant: Bool = false) {
        for (index, mark) in marks.enumerated() {
            if vacant {
                mark.backgroundColor = AuxColor.background
                mark.layer.borderColor = AuxColor.background.cgColor
            } else if index < filled {
                mark.backgroundColor = AuxColor.accent
                mark.layer.borderColor = AuxColor.ink.withAlphaComponent(0.35).cgColor
            } else {
                mark.backgroundColor = AuxColor.surface
                mark.layer.borderColor = AuxColor.muted.cgColor
            }
        }
    }
}

/// Role: sealed-day and filed-ring counts for the open month.
@MainActor
final class MonthSummaryTile: UIView {
    private let tile = AuxTile()
    private let key = UILabel()
    private let sealed = UILabel()
    private let rings = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        key.translatesAutoresizingMaskIntoConstraints = false
        key.adjustsFontForContentSizeCategory = true

        sealed.translatesAutoresizingMaskIntoConstraints = false
        sealed.font = AuxType.body()
        sealed.textColor = AuxColor.ink
        sealed.adjustsFontForContentSizeCategory = true
        sealed.adjustsFontSizeToFitWidth = true
        sealed.minimumScaleFactor = 0.8

        rings.translatesAutoresizingMaskIntoConstraints = false
        rings.font = AuxType.body()
        rings.textColor = AuxColor.ink
        rings.adjustsFontForContentSizeCategory = true
        rings.adjustsFontSizeToFitWidth = true
        rings.minimumScaleFactor = 0.8
        rings.textAlignment = .right

        addSubview(tile)
        tile.addSubview(key)
        tile.addSubview(sealed)
        tile.addSubview(rings)
        NSLayoutConstraint.activate([
            tile.topAnchor.constraint(equalTo: topAnchor),
            tile.leadingAnchor.constraint(equalTo: leadingAnchor),
            tile.trailingAnchor.constraint(equalTo: trailingAnchor),
            tile.bottomAnchor.constraint(equalTo: bottomAnchor),
            key.topAnchor.constraint(equalTo: tile.topAnchor, constant: AuxSpace.step(1)),
            key.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: AuxSpace.step(2)),
            key.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: -AuxSpace.step(2)),
            sealed.topAnchor.constraint(equalTo: key.bottomAnchor, constant: AuxSpace.unit),
            sealed.leadingAnchor.constraint(equalTo: key.leadingAnchor),
            sealed.bottomAnchor.constraint(equalTo: tile.bottomAnchor, constant: -AuxSpace.step(1)),
            rings.centerYAnchor.constraint(equalTo: sealed.centerYAnchor),
            rings.trailingAnchor.constraint(equalTo: key.trailingAnchor),
            rings.leadingAnchor.constraint(greaterThanOrEqualTo: sealed.trailingAnchor, constant: AuxSpace.unit),
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
        ])
        isAccessibilityElement = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This summary is built in code.")
    }

    func apply(month: String, sealedDays: Int, ringCount: Int) {
        key.attributedText = AuxType.hairlineAttributed(month, color: AuxColor.muted)
        sealed.text = "\(AuxFormat.integer(sealedDays)) sealed days"
        rings.text = "\(AuxFormat.integer(ringCount)) rings filed"
        accessibilityLabel = "\(month), \(sealed.text ?? ""), \(rings.text ?? "")"
    }
}
