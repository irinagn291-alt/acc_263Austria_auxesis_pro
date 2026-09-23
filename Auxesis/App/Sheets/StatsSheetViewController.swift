import AuxCanvasCore
import AuxCanvasStore
import AuxRingKit
import UIKit

/// Role: month ring history plus four counts. The sheet is the mechanic, not a short stack.
@MainActor
final class StatsSheetViewController: UIViewController {
    private let store: AuxStore
    private let header = SheetHeaderView(title: "Stats")
    private let empty: AuxEmptyState
    private let error: AuxEmptyState
    private let body = UIView()
    private let monthCard = MonthStatCard()
    private let fullTile = StatTile(key: "Sealed")
    private let ringTile = StatTile(key: "Rings")
    private let longTile = StatTile(key: "Longest")
    private let streakTile = StatTile(key: "Streak")
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private var loadTask: Task<Void, Never>?

    init(store: AuxStore) {
        self.store = store
        empty = AuxEmptyState(
            image: AuxAsset.image(AuxAsset.statsEmpty),
            headlineText: "No rings have been counted.",
            lineText: "A day with one seeded ring is enough to start the ledger.",
            actionTitle: "Back to canvas"
        )
        error = AuxEmptyState(
            image: AuxAsset.image(AuxAsset.emptyList),
            headlineText: "Stats could not load.",
            lineText: "Counts stay on this device. Retry reads the store again.",
            actionTitle: "Retry"
        )
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
        empty.actionButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        error.actionButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        empty.isHidden = true
        error.isHidden = true

        body.translatesAutoresizingMaskIntoConstraints = false
        [fullTile, ringTile, longTile, streakTile].forEach { tile in
            tile.setContentHuggingPriority(.required, for: .vertical)
            tile.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        fullTile.setLead(true)

        view.addSubview(header)
        view.addSubview(body)
        body.addSubview(monthCard)
        body.addSubview(fullTile)
        body.addSubview(ringTile)
        body.addSubview(longTile)
        body.addSubview(streakTile)
        view.addSubview(empty)
        view.addSubview(error)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(1)),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuxSpace.step(2)),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuxSpace.step(2)),

            body.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AuxSpace.step(1)),
            body.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            body.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -AuxSpace.step(2)),

            empty.topAnchor.constraint(equalTo: body.topAnchor),
            empty.leadingAnchor.constraint(equalTo: body.leadingAnchor),
            empty.trailingAnchor.constraint(equalTo: body.trailingAnchor),
            empty.bottomAnchor.constraint(equalTo: body.bottomAnchor),

            error.topAnchor.constraint(equalTo: empty.topAnchor),
            error.leadingAnchor.constraint(equalTo: empty.leadingAnchor),
            error.trailingAnchor.constraint(equalTo: empty.trailingAnchor),
            error.bottomAnchor.constraint(equalTo: empty.bottomAnchor),
        ])

        compactConstraints = [
            fullTile.topAnchor.constraint(equalTo: body.topAnchor),
            fullTile.leadingAnchor.constraint(equalTo: body.leadingAnchor),
            fullTile.widthAnchor.constraint(equalTo: body.widthAnchor, multiplier: 0.62),
            fullTile.heightAnchor.constraint(equalToConstant: AuxSpace.step(16)),

            ringTile.topAnchor.constraint(equalTo: fullTile.topAnchor),
            ringTile.leadingAnchor.constraint(equalTo: fullTile.trailingAnchor, constant: AuxSpace.unit),
            ringTile.trailingAnchor.constraint(equalTo: body.trailingAnchor),
            ringTile.heightAnchor.constraint(equalToConstant: AuxSpace.step(8)),

            longTile.topAnchor.constraint(equalTo: ringTile.bottomAnchor, constant: AuxSpace.unit),
            longTile.leadingAnchor.constraint(equalTo: ringTile.leadingAnchor),
            longTile.trailingAnchor.constraint(equalTo: ringTile.trailingAnchor),
            longTile.heightAnchor.constraint(equalToConstant: AuxSpace.step(7)),

            streakTile.topAnchor.constraint(equalTo: longTile.bottomAnchor, constant: AuxSpace.unit),
            streakTile.leadingAnchor.constraint(equalTo: ringTile.leadingAnchor),
            streakTile.trailingAnchor.constraint(equalTo: ringTile.trailingAnchor),
            streakTile.bottomAnchor.constraint(equalTo: fullTile.bottomAnchor),

            monthCard.topAnchor.constraint(equalTo: fullTile.bottomAnchor, constant: AuxSpace.unit),
            monthCard.leadingAnchor.constraint(equalTo: body.leadingAnchor),
            monthCard.trailingAnchor.constraint(equalTo: body.trailingAnchor),
            monthCard.bottomAnchor.constraint(equalTo: body.bottomAnchor),
        ]

        regularConstraints = [
            monthCard.topAnchor.constraint(equalTo: body.topAnchor),
            monthCard.leadingAnchor.constraint(equalTo: body.leadingAnchor),
            monthCard.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            monthCard.widthAnchor.constraint(equalTo: body.widthAnchor, multiplier: 0.68),

            fullTile.topAnchor.constraint(equalTo: body.topAnchor),
            fullTile.leadingAnchor.constraint(equalTo: monthCard.trailingAnchor, constant: AuxSpace.unit),
            fullTile.trailingAnchor.constraint(equalTo: body.trailingAnchor),
            fullTile.heightAnchor.constraint(equalTo: body.heightAnchor, multiplier: 0.34),

            ringTile.topAnchor.constraint(equalTo: fullTile.bottomAnchor, constant: AuxSpace.unit),
            ringTile.leadingAnchor.constraint(equalTo: fullTile.leadingAnchor),
            ringTile.trailingAnchor.constraint(equalTo: fullTile.trailingAnchor),

            longTile.topAnchor.constraint(equalTo: ringTile.bottomAnchor, constant: AuxSpace.unit),
            longTile.leadingAnchor.constraint(equalTo: fullTile.leadingAnchor),
            longTile.trailingAnchor.constraint(equalTo: fullTile.trailingAnchor),
            longTile.heightAnchor.constraint(equalTo: ringTile.heightAnchor),

            streakTile.topAnchor.constraint(equalTo: longTile.bottomAnchor, constant: AuxSpace.unit),
            streakTile.leadingAnchor.constraint(equalTo: fullTile.leadingAnchor),
            streakTile.trailingAnchor.constraint(equalTo: fullTile.trailingAnchor),
            streakTile.bottomAnchor.constraint(equalTo: body.bottomAnchor),
            streakTile.heightAnchor.constraint(equalTo: ringTile.heightAnchor),
        ]

        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (screen: StatsSheetViewController, _) in
            screen.applyLayoutTraits()
        }
        applyLayoutTraits()
        reload()
    }

    private func applyLayoutTraits() {
        NSLayoutConstraint.deactivate(compactConstraints)
        NSLayoutConstraint.deactivate(regularConstraints)
        let regular = traitCollection.horizontalSizeClass == .regular
        NSLayoutConstraint.activate(regular ? regularConstraints : compactConstraints)
    }

    @objc private func close() {
        dismiss(animated: AuxMotion.shouldTravel)
    }

    @objc private func reload() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.load()
        }
    }

    private func load() async {
        do {
            let now = Date()
            let calendar = Calendar.current
            let stats = try await store.stats(now: now, calendar: calendar)
            let days = try await store.practices()
            error.isHidden = true
            let vacant = stats.ringLayerCount == 0
            empty.isHidden = !vacant
            body.isHidden = vacant
            let monthDays = Self.monthPractices(from: days, now: now, calendar: calendar)
            let filed = monthDays.reduce(0) { $0 + $1.ringCount }
            monthCard.apply(
                filed: filed,
                days: monthDays,
                now: now,
                calendar: calendar
            )
            fullTile.set(value: AuxFormat.integer(stats.fullMarkCount), caption: "Sealed days")
            ringTile.set(value: AuxFormat.integer(stats.ringLayerCount), caption: "Filed rings")
            longTile.set(value: AuxFormat.minutes(stats.longestRingSeconds), caption: "Longest span")
            streakTile.set(value: AuxFormat.integer(stats.consecutiveDayStreak), caption: "Consecutive days")
        } catch {
            self.error.isHidden = false
            empty.isHidden = true
            body.isHidden = true
        }
    }

    private static func monthPractices(
        from days: [PracticeDay],
        now: Date,
        calendar: Calendar
    ) -> [PracticeDay] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let length = calendar.range(of: .day, in: .month, for: start)?.count ?? 30
        let map = Dictionary(uniqueKeysWithValues: days.map { ($0.dayKey, $0) })
        return (0 ..< length).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            let key = DayKey.of(date, calendar: calendar)
            return map[key] ?? PracticeDay(dayKey: key, ringCount: 0, isSealed: false, durations: [])
        }
    }
}

@MainActor
final class MonthStatCard: UIView {
    private let tile = AuxTile()
    private let column = UIStackView()
    private let header = UIView()
    private let footer = UIView()
    private let keyLabel = UILabel()
    private let valueLabel = UILabel()
    private let caption = UILabel()
    private let history = MonthRingHistoryView()
    private let picked = UILabel()
    private let rings = UIStackView()
    private var displayed = 0
    private var timer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.attributedText = AuxType.hairlineAttributed("This month", color: AuxColor.muted)
        keyLabel.adjustsFontForContentSizeCategory = true
        keyLabel.setContentHuggingPriority(.required, for: .vertical)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = AuxType.canvasFigure()
        valueLabel.textColor = AuxColor.ink
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        valueLabel.text = AuxFormat.integer(0)
        valueLabel.setContentHuggingPriority(.required, for: .vertical)

        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.font = AuxType.caption()
        caption.textColor = AuxColor.muted
        caption.adjustsFontForContentSizeCategory = true
        caption.text = "Rings this month"
        caption.setContentHuggingPriority(.required, for: .vertical)

        picked.translatesAutoresizingMaskIntoConstraints = false
        picked.font = AuxType.body()
        picked.textColor = AuxColor.ink
        picked.adjustsFontForContentSizeCategory = true
        picked.adjustsFontSizeToFitWidth = true
        picked.minimumScaleFactor = 0.7
        picked.numberOfLines = 2
        picked.setContentHuggingPriority(.required, for: .vertical)

        rings.translatesAutoresizingMaskIntoConstraints = false
        rings.axis = .horizontal
        rings.distribution = .fillEqually
        rings.spacing = AuxSpace.unit

        history.setContentHuggingPriority(.defaultLow, for: .vertical)
        history.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        history.onSelect = { [weak self] day in
            self?.show(day)
        }

        header.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(keyLabel)
        header.addSubview(valueLabel)
        header.addSubview(caption)
        header.setContentHuggingPriority(.required, for: .vertical)

        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(picked)
        footer.addSubview(rings)
        footer.setContentHuggingPriority(.required, for: .vertical)

        column.translatesAutoresizingMaskIntoConstraints = false
        column.axis = .vertical
        column.spacing = AuxSpace.unit
        column.alignment = .fill
        column.distribution = .fill
        column.addArrangedSubview(header)
        column.addArrangedSubview(history)
        column.addArrangedSubview(footer)

        addSubview(tile)
        tile.addSubview(column)
        NSLayoutConstraint.activate([
            tile.topAnchor.constraint(equalTo: topAnchor),
            tile.leadingAnchor.constraint(equalTo: leadingAnchor),
            tile.trailingAnchor.constraint(equalTo: trailingAnchor),
            tile.bottomAnchor.constraint(equalTo: bottomAnchor),
            column.topAnchor.constraint(equalTo: tile.topAnchor, constant: AuxSpace.step(1)),
            column.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: AuxSpace.step(2)),
            column.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: -AuxSpace.step(2)),
            column.bottomAnchor.constraint(equalTo: tile.bottomAnchor, constant: -AuxSpace.step(1)),

            keyLabel.topAnchor.constraint(equalTo: header.topAnchor),
            keyLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            keyLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: 2),
            valueLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            caption.leadingAnchor.constraint(greaterThanOrEqualTo: valueLabel.trailingAnchor, constant: AuxSpace.unit),
            caption.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            caption.lastBaselineAnchor.constraint(equalTo: valueLabel.lastBaselineAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor),

            picked.topAnchor.constraint(equalTo: footer.topAnchor),
            picked.leadingAnchor.constraint(equalTo: footer.leadingAnchor),
            picked.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
            rings.topAnchor.constraint(equalTo: picked.bottomAnchor, constant: AuxSpace.unit),
            rings.leadingAnchor.constraint(equalTo: footer.leadingAnchor),
            rings.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
            rings.bottomAnchor.constraint(equalTo: footer.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This month card is built in code.")
    }

    func apply(filed: Int, days: [PracticeDay], now: Date, calendar: Calendar) {
        caption.text = "Rings this month"
        history.apply(days: days, calendar: calendar, now: now)
        if AuxMotion.shouldTravel, filed > 0 {
            tick(to: filed)
        } else {
            timer?.invalidate()
            valueLabel.text = AuxFormat.integer(filed)
        }
    }

    private func show(_ day: PracticeDay) {
        let status = day.isSealed
            ? "Sealed. \(AuxFormat.ringsOutOfSeven(day.ringCount))"
            : AuxFormat.ringsOutOfSeven(day.ringCount)
        picked.text = "\(AuxFormat.day(day.dayKey)). \(status)"
        rings.arrangedSubviews.forEach { view in
            rings.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for index in 0 ..< FullMarkSeal.ringCapacity {
            let chip = RingSpanChip()
            if index < day.durations.count {
                chip.apply(
                    title: "\(AuxFormat.integer(index + 1))\n\(AuxFormat.minutes(day.durations[index]))",
                    filled: true
                )
            } else {
                chip.apply(title: "\(AuxFormat.integer(index + 1))\nOpen", filled: false)
            }
            rings.addArrangedSubview(chip)
        }
    }

    private func tick(to target: Int) {
        timer?.invalidate()
        displayed = 0
        valueLabel.text = AuxFormat.integer(0)
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let step = max(1, target / 12)
                self.displayed = min(target, self.displayed + step)
                self.valueLabel.text = AuxFormat.integer(self.displayed)
                if self.displayed >= target {
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
}

@MainActor
final class StatTile: UIView {
    private let tile = AuxTile()
    private let keyLabel = UILabel()
    private let valueLabel = UILabel()
    private let caption = UILabel()
    private var displayed = 0
    private var timer: Timer?

    init(key: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.attributedText = AuxType.hairlineAttributed(key, color: AuxColor.muted)
        keyLabel.adjustsFontForContentSizeCategory = true

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = AuxType.sectionTitle()
        valueLabel.textColor = AuxColor.ink
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        valueLabel.text = AuxFormat.integer(0)

        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.font = AuxType.caption()
        caption.textColor = AuxColor.muted
        caption.adjustsFontForContentSizeCategory = true
        caption.numberOfLines = 2

        addSubview(tile)
        tile.addSubview(keyLabel)
        tile.addSubview(valueLabel)
        tile.addSubview(caption)
        NSLayoutConstraint.activate([
            tile.topAnchor.constraint(equalTo: topAnchor),
            tile.leadingAnchor.constraint(equalTo: leadingAnchor),
            tile.trailingAnchor.constraint(equalTo: trailingAnchor),
            tile.bottomAnchor.constraint(equalTo: bottomAnchor),
            keyLabel.topAnchor.constraint(equalTo: tile.topAnchor, constant: AuxSpace.step(1)),
            keyLabel.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: AuxSpace.step(2)),
            keyLabel.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: -AuxSpace.step(2)),
            valueLabel.topAnchor.constraint(equalTo: keyLabel.bottomAnchor, constant: AuxSpace.unit),
            valueLabel.leadingAnchor.constraint(equalTo: keyLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: keyLabel.trailingAnchor),
            caption.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: AuxSpace.unit),
            caption.leadingAnchor.constraint(equalTo: keyLabel.leadingAnchor),
            caption.trailingAnchor.constraint(equalTo: keyLabel.trailingAnchor),
            caption.bottomAnchor.constraint(equalTo: tile.bottomAnchor, constant: -AuxSpace.step(1)),
        ])
    }

    func setLead(_ lead: Bool) {
        valueLabel.font = lead ? AuxType.canvasFigure() : AuxType.sectionTitle()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This tile is built in code.")
    }

    func set(value: String, caption line: String) {
        caption.text = line
        if let number = Int(value.filter(\.isNumber)), AuxMotion.shouldTravel, !value.contains("min") || number < 100 {
            tick(to: number, formatted: value)
        } else {
            timer?.invalidate()
            valueLabel.text = value
        }
    }

    private func tick(to target: Int, formatted: String) {
        timer?.invalidate()
        displayed = 0
        valueLabel.text = AuxFormat.integer(0)
        guard target > 0 else {
            valueLabel.text = formatted
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                let step = max(1, target / 12)
                self.displayed = min(target, self.displayed + step)
                if self.displayed >= target {
                    self.valueLabel.text = formatted
                    self.timer?.invalidate()
                    self.timer = nil
                } else {
                    self.valueLabel.text = AuxFormat.integer(self.displayed)
                }
            }
        }
    }
}
