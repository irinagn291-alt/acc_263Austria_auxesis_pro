import AuxRingKit
import UIKit

/// Role: rings-per-day bars that earn the area under a stat.
@MainActor
final class RingTrendView: UIView {
    private let row = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.alignment = .bottom
        row.distribution = .fillEqually
        row.spacing = 2
        addSubview(row)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: AuxSpace.step(6)),
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This trend is built in code.")
    }

    func apply(counts: [Int]) {
        row.arrangedSubviews.forEach { bar in
            row.removeArrangedSubview(bar)
            bar.removeFromSuperview()
        }
        let peak = max(counts.max() ?? 0, 1)
        for count in counts {
            let wrap = UIView()
            wrap.translatesAutoresizingMaskIntoConstraints = false
            let fill = UIView()
            fill.translatesAutoresizingMaskIntoConstraints = false
            fill.backgroundColor = count > 0 ? AuxColor.accent : AuxColor.muted.withAlphaComponent(0.35)
            fill.layer.cornerRadius = AuxRadius.chip
            wrap.addSubview(fill)
            let ratio = CGFloat(count) / CGFloat(peak)
            NSLayoutConstraint.activate([
                fill.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
                fill.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
                fill.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
                fill.heightAnchor.constraint(equalTo: wrap.heightAnchor, multiplier: max(0.12, ratio)),
            ])
            row.addArrangedSubview(wrap)
        }
    }
}
