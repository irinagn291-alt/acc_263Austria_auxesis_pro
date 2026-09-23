import AuxCanvasCore
import AuxRingKit
import UIKit

/// Role: the day's seven ring slots as labeled marks, not empty ornaments.
@MainActor
final class DayRingTrackView: UIView {
    private let title = UILabel()
    private let row = UIStackView()
    private var slots: [RingSpanChip] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        title.translatesAutoresizingMaskIntoConstraints = false
        title.attributedText = AuxType.hairlineAttributed("Seven rings seal the day", color: AuxColor.muted)
        title.adjustsFontForContentSizeCategory = true

        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = AuxSpace.unit
        row.alignment = .fill

        for index in 1 ... FullMarkSeal.ringCapacity {
            let mark = RingSpanChip()
            row.addArrangedSubview(mark)
            slots.append(mark)
            mark.accessibilityLabel = "Ring \(AuxFormat.integer(index))"
        }

        addSubview(title)
        addSubview(row)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.topAnchor.constraint(equalTo: title.bottomAnchor, constant: AuxSpace.unit),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This track is built in code.")
    }

    func setColumnAxis(_ axis: NSLayoutConstraint.Axis) {
        row.axis = axis
    }

    func apply(rings: [Ring]) {
        for (index, mark) in slots.enumerated() {
            let number = AuxFormat.integer(index + 1)
            if index < rings.count {
                let span = AuxFormat.minutes(rings[index].duration.seconds)
                mark.apply(title: "\(number)\n\(span)", filled: true)
                mark.accessibilityLabel = "Ring \(number), \(span)"
            } else {
                mark.apply(title: "\(number)\nOpen", filled: false)
                mark.accessibilityLabel = "Ring \(number) open"
            }
        }
    }

}

/// Role: one ring-span readout. Type only. No plate, no hit target.
@MainActor
final class RingSpanChip: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        isAccessibilityElement = true
        backgroundColor = .clear

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AuxType.caption()
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.6
        label.numberOfLines = 2
        label.textAlignment = .center
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This chip is built in code.")
    }

    func apply(title: String, filled: Bool) {
        label.text = title
        label.textColor = filled ? AuxColor.ink : AuxColor.muted
        accessibilityLabel = title.replacingOccurrences(of: "\n", with: ", ")
    }
}

/// Role: today's seven rings as a mixed bento. One filed span leads. Open slots stay Buttons.
@MainActor
final class RoundHistoryView: UIView {
    var onOpen: (() -> Void)?

    private let title = UILabel()
    private let board = UIView()
    private var cells: [RingStratumButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        title.translatesAutoresizingMaskIntoConstraints = false
        title.attributedText = AuxType.hairlineAttributed("Rounds filed today", color: AuxColor.muted)
        title.adjustsFontForContentSizeCategory = true

        board.translatesAutoresizingMaskIntoConstraints = false
        for _ in 0 ..< FullMarkSeal.ringCapacity {
            let cell = RingStratumButton()
            cell.addTarget(self, action: #selector(openHistory), for: .touchUpInside)
            board.addSubview(cell)
            cells.append(cell)
        }

        addSubview(title)
        addSubview(board)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            board.topAnchor.constraint(equalTo: title.bottomAnchor, constant: AuxSpace.unit),
            board.leadingAnchor.constraint(equalTo: leadingAnchor),
            board.trailingAnchor.constraint(equalTo: trailingAnchor),
            board.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        pinBento()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This history is built in code.")
    }

    func apply(rings: [Ring]) {
        for (index, cell) in cells.enumerated() {
            if index < rings.count {
                let span = AuxFormat.minutes(rings[index].duration.seconds)
                cell.apply(
                    key: "Ring \(AuxFormat.integer(index + 1))",
                    value: span,
                    open: false,
                    lead: index == 0
                )
            } else {
                cell.apply(
                    key: "Ring \(AuxFormat.integer(index + 1))",
                    value: "Open",
                    open: true,
                    lead: false
                )
            }
        }
    }

    private func pinBento() {
        let gap = AuxSpace.unit
        let lead = cells[0]
        let midA = cells[1]
        let midB = cells[2]
        let wide = cells[3]
        let tail = Array(cells[4...])
        NSLayoutConstraint.activate([
            lead.topAnchor.constraint(equalTo: board.topAnchor),
            lead.leadingAnchor.constraint(equalTo: board.leadingAnchor),
            lead.widthAnchor.constraint(equalTo: board.widthAnchor, multiplier: 0.58),
            lead.heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit * 2 + gap),

            midA.topAnchor.constraint(equalTo: lead.topAnchor),
            midA.leadingAnchor.constraint(equalTo: lead.trailingAnchor, constant: gap),
            midA.trailingAnchor.constraint(equalTo: board.trailingAnchor),
            midA.heightAnchor.constraint(equalTo: midB.heightAnchor),

            midB.topAnchor.constraint(equalTo: midA.bottomAnchor, constant: gap),
            midB.leadingAnchor.constraint(equalTo: midA.leadingAnchor),
            midB.trailingAnchor.constraint(equalTo: midA.trailingAnchor),
            midB.bottomAnchor.constraint(equalTo: lead.bottomAnchor),

            wide.topAnchor.constraint(equalTo: lead.bottomAnchor, constant: gap),
            wide.leadingAnchor.constraint(equalTo: board.leadingAnchor),
            wide.widthAnchor.constraint(equalTo: board.widthAnchor, multiplier: 0.34),
            wide.bottomAnchor.constraint(equalTo: board.bottomAnchor),
            wide.heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
        ])
        var previous: UIView = wide
        for (index, cell) in tail.enumerated() {
            cell.topAnchor.constraint(equalTo: wide.topAnchor).isActive = true
            cell.bottomAnchor.constraint(equalTo: wide.bottomAnchor).isActive = true
            cell.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: gap).isActive = true
            if index == tail.count - 1 {
                cell.trailingAnchor.constraint(equalTo: board.trailingAnchor).isActive = true
            }
            if index > 0 {
                cell.widthAnchor.constraint(equalTo: tail[0].widthAnchor).isActive = true
            }
            previous = cell
        }
    }

    @objc private func openHistory() {
        onOpen?()
    }
}

@MainActor
private final class RingStratumButton: UIButton {
    private let keyLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        AuxElevation.apply(to: self)

        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.adjustsFontForContentSizeCategory = true
        keyLabel.isUserInteractionEnabled = false

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.textColor = AuxColor.ink
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        valueLabel.isUserInteractionEnabled = false

        addSubview(keyLabel)
        addSubview(valueLabel)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
            keyLabel.topAnchor.constraint(equalTo: topAnchor, constant: AuxSpace.step(1)),
            keyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AuxSpace.step(1)),
            keyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AuxSpace.step(1)),
            valueLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 2),
            valueLabel.leadingAnchor.constraint(equalTo: keyLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: keyLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -AuxSpace.unit),
        ])
        configurationUpdateHandler = { button in
            button.alpha = button.isHighlighted ? 0.72 : 1
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This ring tile is built in code.")
    }

    func apply(key: String, value: String, open: Bool, lead: Bool) {
        keyLabel.attributedText = AuxType.hairlineAttributed(key, color: AuxColor.muted)
        valueLabel.text = value
        valueLabel.font = lead ? AuxType.sectionTitle() : AuxType.body()
        valueLabel.textColor = open ? AuxColor.muted : AuxColor.ink
        accessibilityLabel = "\(key), \(value)"
    }
}
