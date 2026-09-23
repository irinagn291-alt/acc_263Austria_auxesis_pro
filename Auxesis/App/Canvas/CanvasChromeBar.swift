import AuxRingKit
import UIKit

/// Role: hairline bottom chrome. Practices, Stats, and Settings. Never a tab bar.
@MainActor
final class CanvasChromeBar: UIView {
    let practices = AuxButton(title: "Practices", kind: .chrome)
    let stats = AuxButton(title: "Stats", kind: .chrome)
    let settings = AuxButton(title: "Settings", kind: .chrome)

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AuxColor.background

        let rule = AuxHairline()
        let row = UIStackView(arrangedSubviews: [practices, stats, settings])
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.spacing = AuxSpace.step(1)
        row.distribution = .fillEqually
        row.alignment = .fill

        addSubview(rule)
        addSubview(row)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.step(8)),
            rule.topAnchor.constraint(equalTo: topAnchor),
            rule.leadingAnchor.constraint(equalTo: leadingAnchor),
            rule.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.topAnchor.constraint(equalTo: rule.bottomAnchor, constant: AuxSpace.step(1)),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This chrome is built in code.")
    }
}
