import AuxCanvasCore
import AuxCanvasStore
import AuxRingKit
import UIKit

/// Role: a month of ring completion. Heading sits on the grid. Each day is a Button.
@MainActor
final class MonthRingGridView: UIView {
    var onSelect: ((PracticeDay?) -> Void)?

    private let column = UIStackView()
    private let monthLabel = UILabel()
    private let footer = UILabel()
    private let weekRow = UIStackView()
    private let grid = UIStackView()
    private var cells: [DayCell] = []
    private var daysByKey: [DayKey: PracticeDay] = [:]
    private var selected: DayKey?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = AuxType.sectionTitle()
        monthLabel.textColor = AuxColor.ink
        monthLabel.adjustsFontForContentSizeCategory = true
        monthLabel.setContentHuggingPriority(.required, for: .vertical)
        monthLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.font = AuxType.caption()
        footer.textColor = AuxColor.muted
        footer.numberOfLines = 2
        footer.adjustsFontForContentSizeCategory = true
        footer.setContentHuggingPriority(.required, for: .vertical)
        footer.setContentCompressionResistancePriority(.required, for: .vertical)

        weekRow.axis = .horizontal
        weekRow.distribution = .fillEqually
        weekRow.spacing = AuxSpace.unit
        weekRow.translatesAutoresizingMaskIntoConstraints = false
        weekRow.setContentHuggingPriority(.required, for: .vertical)

        grid.axis = .vertical
        grid.spacing = AuxSpace.unit
        grid.distribution = .fillEqually
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.setContentHuggingPriority(.defaultLow, for: .vertical)
        grid.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.alignment = .fill
        column.spacing = AuxSpace.step(1)
        column.addArrangedSubview(monthLabel)
        column.addArrangedSubview(footer)
        column.addArrangedSubview(weekRow)
        column.addArrangedSubview(grid)

        addSubview(column)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: topAnchor),
            column.leadingAnchor.constraint(equalTo: leadingAnchor),
            column.trailingAnchor.constraint(equalTo: trailingAnchor),
            column.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This month grid is built in code.")
    }

    func apply(days: [PracticeDay], calendar: Calendar = .current, now: Date = Date()) {
        daysByKey = Dictionary(uniqueKeysWithValues: days.map { ($0.dayKey, $0) })
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let monthKey = DayKey.of(monthStart, calendar: calendar)
        monthLabel.text = AuxFormat.month(monthKey, calendar: calendar)
        let monthDays = days.filter { AuxFormat.month($0.dayKey, calendar: calendar) == monthLabel.text }
        let sealedDays = monthDays.filter(\.isSealed).count
        let ringCount = monthDays.reduce(0) { $0 + $1.ringCount }
        footer.text = "\(AuxFormat.integer(sealedDays)) sealed days. \(AuxFormat.integer(ringCount)) rings filed."

        weekRow.arrangedSubviews.forEach { view in
            weekRow.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        let symbols = calendar.veryShortWeekdaySymbols
        let first = calendar.firstWeekday - 1
        for offset in 0 ..< 7 {
            let label = UILabel()
            label.textAlignment = .center
            label.attributedText = AuxType.hairlineAttributed(
                symbols[(first + offset) % symbols.count],
                color: AuxColor.muted
            )
            label.adjustsFontForContentSizeCategory = true
            weekRow.addArrangedSubview(label)
        }

        grid.arrangedSubviews.forEach { row in
            grid.removeArrangedSubview(row)
            row.removeFromSuperview()
        }
        cells.removeAll()

        let weekday = calendar.component(.weekday, from: monthStart)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        let count = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        var items: [Date?] = Array(repeating: nil, count: leading)
        for day in 1 ... count {
            items.append(calendar.date(byAdding: .day, value: day - 1, to: monthStart))
        }
        while items.count % 7 != 0 {
            items.append(nil)
        }

        for chunk in stride(from: 0, to: items.count, by: 7) {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = AuxSpace.unit
            for date in items[chunk ..< chunk + 7] {
                let cell = DayCell()
                cell.addTarget(self, action: #selector(pick(_:)), for: .touchUpInside)
                if let date {
                    let key = DayKey.of(date, calendar: calendar)
                    cell.apply(dayKey: key, practice: daysByKey[key], calendar: calendar)
                    cell.isEnabled = true
                } else {
                    cell.applyEmpty()
                    cell.isEnabled = false
                }
                row.addArrangedSubview(cell)
                cells.append(cell)
            }
            grid.addArrangedSubview(row)
        }
        if selected == nil {
            selected = DayKey.of(now, calendar: calendar)
        }
        refreshSelection()
        notifySelection()
    }

    @objc private func pick(_ cell: DayCell) {
        guard let key = cell.dayKey else { return }
        selected = key
        refreshSelection()
        notifySelection()
    }

    private func refreshSelection() {
        for cell in cells {
            cell.setChosen(cell.dayKey == selected)
        }
    }

    private func notifySelection() {
        guard let selected else {
            onSelect?(nil)
            return
        }
        onSelect?(daysByKey[selected] ?? PracticeDay(dayKey: selected, ringCount: 0, isSealed: false, durations: []))
    }
}

@MainActor
private final class DayCell: UIButton {
    private(set) var dayKey: DayKey?
    private let number = UILabel()
    private let slots = RingSlotColumn(axis: .horizontal)

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.title = nil
        config.background.backgroundColor = AuxColor.surface
        config.background.cornerRadius = AuxRadius.chip
        config.background.strokeWidth = AuxElevation.borderWidth
        configuration = config
        AuxElevation.apply(to: self, radius: AuxRadius.chip)

        number.translatesAutoresizingMaskIntoConstraints = false
        number.font = AuxType.dayMark()
        number.textColor = AuxColor.ink
        number.textAlignment = .center
        number.adjustsFontForContentSizeCategory = false
        number.adjustsFontSizeToFitWidth = false
        number.lineBreakMode = .byClipping
        number.numberOfLines = 1
        number.setContentHuggingPriority(.required, for: .vertical)
        number.setContentCompressionResistancePriority(.required, for: .vertical)
        number.setContentCompressionResistancePriority(.required, for: .horizontal)
        number.isUserInteractionEnabled = false

        addSubview(number)
        addSubview(slots)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
            number.topAnchor.constraint(equalTo: topAnchor, constant: AuxSpace.unit / 2),
            number.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            number.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            number.heightAnchor.constraint(equalToConstant: 20),
            slots.topAnchor.constraint(equalTo: number.bottomAnchor, constant: 2),
            slots.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AuxSpace.unit / 2),
            slots.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AuxSpace.unit / 2),
            slots.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -2),
        ])
        configurationUpdateHandler = { [weak self] button in
            self?.alpha = button.isHighlighted ? 0.72 : 1
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This day cell is built in code.")
    }

    func applyEmpty() {
        dayKey = nil
        number.text = ""
        accessibilityLabel = "Empty"
        backgroundColor = AuxColor.background
        slots.apply(filled: 0, vacant: true)
    }

    func apply(dayKey: DayKey, practice: PracticeDay?, calendar: Calendar) {
        self.dayKey = dayKey
        number.text = AuxFormat.dayOfMonth(dayKey, calendar: calendar)
        slots.apply(filled: practice?.ringCount ?? 0)
        if let practice, practice.ringCount > 0 {
            let status = practice.isSealed ? "Sealed" : AuxFormat.ringsOutOfSeven(practice.ringCount)
            accessibilityLabel = "\(AuxFormat.day(dayKey, calendar: calendar)), \(status)"
        } else {
            accessibilityLabel = "\(AuxFormat.day(dayKey, calendar: calendar)), open"
        }
        backgroundColor = AuxColor.surface
    }

    func setChosen(_ chosen: Bool) {
        layer.borderColor = (chosen ? AuxColor.accent : AuxColor.muted.withAlphaComponent(0.35)).cgColor
        layer.borderWidth = AuxElevation.borderWidth
    }
}
