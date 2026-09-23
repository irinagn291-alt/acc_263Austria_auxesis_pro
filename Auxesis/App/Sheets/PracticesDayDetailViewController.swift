import AuxCanvasCore
import AuxCanvasStore
import AuxRingKit
import UIKit

/// Role: one day inside the Practices sheet. Read only when sealed. Stock rows, no second renderer.
@MainActor
final class PracticesDayDetailViewController: UIViewController {
    var onBack: (() -> Void)?
    var showsBack = true

    private let day: PracticeDay
    private let back = AuxButton(title: "Days", kind: .secondary)
    private let titleLabel = UILabel()
    private let status = UILabel()
    private let mark = RingCountMark()
    private let stack = UIStackView()

    init(day: PracticeDay) {
        self.day = day
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This sheet is built in code.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AuxColor.background

        back.addTarget(self, action: #selector(goBack), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = AuxFormat.day(day.dayKey)
        titleLabel.font = AuxType.sectionTitle()
        titleLabel.textColor = AuxColor.ink
        titleLabel.adjustsFontForContentSizeCategory = true

        status.translatesAutoresizingMaskIntoConstraints = false
        status.font = AuxType.body()
        status.textColor = AuxColor.muted
        status.numberOfLines = 2
        status.adjustsFontForContentSizeCategory = true
        if day.isSealed {
            status.text = "Sealed. These spans stay read only."
        } else {
            status.text = "Partial. \(AuxFormat.ringsOutOfSeven(day.ringCount))"
        }

        mark.apply(count: day.ringCount, sealed: day.isSealed)

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = AuxSpace.step(1)
        stack.alignment = .fill
        stack.distribution = .fillEqually

        for index in 0 ..< FullMarkSeal.ringCapacity {
            if index < day.durations.count {
                stack.addArrangedSubview(spanRow(index: index, seconds: day.durations[index]))
            } else {
                stack.addArrangedSubview(openRow(index: index))
            }
        }
        stack.addArrangedSubview(totalRow(seconds: day.durations.reduce(0, +)))

        back.isHidden = !showsBack

        view.addSubview(back)
        view.addSubview(titleLabel)
        view.addSubview(status)
        view.addSubview(mark)
        view.addSubview(stack)

        let guide = view.safeAreaLayoutGuide
        let titleTop = showsBack
            ? titleLabel.topAnchor.constraint(equalTo: back.bottomAnchor, constant: AuxSpace.step(2))
            : titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(1))
        NSLayoutConstraint.activate([
            back.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(1)),
            back.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            back.widthAnchor.constraint(equalToConstant: AuxSpace.step(12)),

            titleTop,
            titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),

            status.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: AuxSpace.unit),
            status.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            status.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            mark.topAnchor.constraint(equalTo: status.bottomAnchor, constant: AuxSpace.step(2)),
            mark.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            mark.widthAnchor.constraint(equalToConstant: AuxSpace.step(14)),
            mark.heightAnchor.constraint(equalToConstant: AuxSpace.step(14)),

            stack.topAnchor.constraint(equalTo: mark.bottomAnchor, constant: AuxSpace.step(2)),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),
            stack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -AuxSpace.step(2)),
        ])
    }

    private func spanRow(index: Int, seconds: Int) -> UIView {
        pairRow(key: "Ring \(AuxFormat.integer(index + 1))", value: AuxFormat.minutes(seconds), muted: false)
    }

    private func openRow(index: Int) -> UIView {
        pairRow(key: "Ring \(AuxFormat.integer(index + 1))", value: "Open", muted: true)
    }

    private func totalRow(seconds: Int) -> UIView {
        pairRow(key: "Day total", value: AuxFormat.minutes(seconds), muted: false)
    }

    private func pairRow(key: String, value: String, muted: Bool) -> UIView {
        let tile = AuxTile()
        let keyLabel = UILabel()
        keyLabel.attributedText = AuxType.hairlineAttributed(key, color: AuxColor.muted)
        keyLabel.adjustsFontForContentSizeCategory = true
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = AuxType.caption()
        valueLabel.textColor = muted ? AuxColor.muted : AuxColor.ink
        valueLabel.adjustsFontForContentSizeCategory = true
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        tile.addSubview(keyLabel)
        tile.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            tile.heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
            keyLabel.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: AuxSpace.step(2)),
            keyLabel.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: -AuxSpace.step(2)),
            valueLabel.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: keyLabel.trailingAnchor, constant: AuxSpace.unit),
        ])
        return tile
    }

    @objc private func goBack() {
        onBack?()
    }
}
