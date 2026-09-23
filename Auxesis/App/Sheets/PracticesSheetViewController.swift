import AuxCanvasCore
import AuxCanvasStore
import AuxRingKit
import UIKit

/// Role: historical canvases by day. Large detent. Detail stays inside this sheet.
@MainActor
final class PracticesSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let store: AuxStore
    private let header = SheetHeaderView(title: "Practices")
    private let table = UITableView(frame: .zero, style: .plain)
    private let month = MonthRingGridView()
    private let summary = MonthSummaryTile()
    private let preview = PracticeDayPreview()
    private let detailHost = UIView()
    private let empty: AuxEmptyState
    private let error: AuxEmptyState
    private var days: [PracticeDay] = []
    private var sections: [(title: String, rows: [PracticeDay])] = []
    private var feed: PracticesResultsController?
    private var loadTask: Task<Void, Never>?
    private var detail: PracticesDayDetailViewController?
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []

    init(store: AuxStore) {
        self.store = store
        empty = AuxEmptyState(
            image: AuxAsset.image(AuxAsset.practicesEmpty),
            headlineText: "No days are filed yet.",
            lineText: "A seeded ring is waiting on today's canvas.",
            actionTitle: "Back to canvas"
        )
        error = AuxEmptyState(
            image: AuxAsset.image(AuxAsset.emptyList),
            headlineText: "Practices could not load.",
            lineText: "The day list stays on this device. Retry reads the store again.",
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
        month.onSelect = { [weak self] day in
            guard let day else { return }
            self?.showDetail(day, embedded: true)
        }

        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = AuxColor.background
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = AuxSpace.step(10)
        table.register(PracticeDayCell.self, forCellReuseIdentifier: PracticeDayCell.reuse)
        table.contentInset.bottom = AuxSpace.step(2)

        month.translatesAutoresizingMaskIntoConstraints = false
        summary.translatesAutoresizingMaskIntoConstraints = false
        preview.translatesAutoresizingMaskIntoConstraints = false
        detailHost.translatesAutoresizingMaskIntoConstraints = false
        detailHost.backgroundColor = AuxColor.background

        empty.isHidden = true
        error.isHidden = true

        view.addSubview(header)
        view.addSubview(summary)
        view.addSubview(table)
        view.addSubview(preview)
        view.addSubview(month)
        view.addSubview(detailHost)
        view.addSubview(empty)
        view.addSubview(error)

        let guide = view.safeAreaLayoutGuide
        let shared: [NSLayoutConstraint] = [
            header.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(1)),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuxSpace.step(2)),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuxSpace.step(2)),

            empty.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AuxSpace.step(1)),
            empty.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            empty.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            empty.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -AuxSpace.step(2)),

            error.topAnchor.constraint(equalTo: empty.topAnchor),
            error.leadingAnchor.constraint(equalTo: empty.leadingAnchor),
            error.trailingAnchor.constraint(equalTo: empty.trailingAnchor),
            error.bottomAnchor.constraint(equalTo: empty.bottomAnchor),
        ]

        compactConstraints = [
            summary.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AuxSpace.step(1)),
            summary.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            summary.trailingAnchor.constraint(equalTo: header.trailingAnchor),

            table.topAnchor.constraint(equalTo: summary.bottomAnchor, constant: AuxSpace.step(1)),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            preview.topAnchor.constraint(equalTo: table.bottomAnchor, constant: AuxSpace.step(1)),
            preview.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            preview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -AuxSpace.step(2)),
            preview.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: 0.28),
        ]

        regularConstraints = [
            month.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AuxSpace.step(2)),
            month.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            month.trailingAnchor.constraint(equalTo: guide.centerXAnchor, constant: -AuxSpace.step(1)),
            month.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -AuxSpace.step(2)),

            detailHost.topAnchor.constraint(equalTo: month.topAnchor),
            detailHost.leadingAnchor.constraint(equalTo: guide.centerXAnchor, constant: AuxSpace.step(1)),
            detailHost.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuxSpace.step(2)),
            detailHost.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -AuxSpace.step(2)),
        ]

        NSLayoutConstraint.activate(shared)
        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (screen: PracticesSheetViewController, _) in
            screen.applyLayoutTraits()
        }
        applyLayoutTraits()
        reload()
    }

    private func applyLayoutTraits() {
        let regular = traitCollection.horizontalSizeClass == .regular
        NSLayoutConstraint.deactivate(compactConstraints)
        NSLayoutConstraint.deactivate(regularConstraints)
        NSLayoutConstraint.activate(regular ? regularConstraints : compactConstraints)
        let vacant = days.isEmpty
        table.isHidden = regular || vacant
        summary.isHidden = regular || vacant
        preview.isHidden = regular || vacant
        month.isHidden = !regular || vacant
        detailHost.isHidden = !regular || vacant
        if !vacant, let first = days.first(where: { $0.dayKey == DayKey.of(Date()) }) ?? days.first {
            preview.apply(first)
            if regular {
                showDetail(first, embedded: true)
            }
        }
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
            let feed = try await store.practicesController()
            self.feed = feed
            feed.onChange = { [weak self] in
                Task { @MainActor in
                    self?.applyFeed()
                }
            }
            applyFeed()
        } catch {
            self.error.isHidden = false
            empty.isHidden = true
            table.isHidden = true
            summary.isHidden = true
            preview.isHidden = true
            month.isHidden = true
            detailHost.isHidden = true
        }
    }

    private func applyFeed() {
        days = (feed?.days ?? []).filter { $0.ringCount > 0 }
        rebuildSections()
        error.isHidden = true
        empty.isHidden = !days.isEmpty
        let now = Date()
        let monthDays = days.filter { AuxFormat.month($0.dayKey) == AuxFormat.month(DayKey.of(now)) }
        summary.apply(
            month: AuxFormat.month(DayKey.of(now)),
            sealedDays: monthDays.filter(\.isSealed).count,
            ringCount: monthDays.reduce(0) { $0 + $1.ringCount }
        )
        month.apply(days: days)
        table.reloadData()
        applyLayoutTraits()
    }

    private func rebuildSections() {
        guard let feed else {
            sections = []
            return
        }
        var next: [(title: String, rows: [PracticeDay])] = []
        for index in 0 ..< feed.sectionCount {
            let rows = feed.days(in: index).filter { $0.ringCount > 0 }
            guard let key = feed.sectionDayKey(at: index), !rows.isEmpty else { continue }
            next.append((AuxFormat.day(key), rows))
        }
        sections = next
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.attributedText = AuxType.hairlineAttributed(sections[section].title, color: AuxColor.muted)
        label.adjustsFontForContentSizeCategory = true
        let wrap = UIView()
        wrap.backgroundColor = AuxColor.background
        label.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: AuxSpace.step(2)),
            label.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -AuxSpace.step(2)),
            label.topAnchor.constraint(equalTo: wrap.topAnchor, constant: AuxSpace.step(2)),
            label.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -AuxSpace.unit),
        ])
        return wrap
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PracticeDayCell.reuse,
            for: indexPath
        ) as? PracticeDayCell else {
            return UITableViewCell()
        }
        cell.apply(sections[indexPath.section].rows[indexPath.row])
        cell.onOpen = { [weak self] day in
            self?.showDetail(day, embedded: false)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        showDetail(sections[indexPath.section].rows[indexPath.row], embedded: false)
    }

    private func showDetail(_ day: PracticeDay, embedded: Bool) {
        preview.apply(day)
        hideDetail()
        let page = PracticesDayDetailViewController(day: day)
        page.showsBack = !embedded
        page.onBack = { [weak self] in
            self?.hideDetail()
        }
        addChild(page)
        page.view.translatesAutoresizingMaskIntoConstraints = false
        page.view.alpha = 0
        let host: UIView = embedded ? detailHost : view
        host.addSubview(page.view)
        let top = embedded ? detailHost.topAnchor : header.bottomAnchor
        NSLayoutConstraint.activate([
            page.view.topAnchor.constraint(equalTo: top),
            page.view.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            page.view.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            page.view.bottomAnchor.constraint(equalTo: host.bottomAnchor),
        ])
        page.didMove(toParent: self)
        detail = page
        AuxMotion.animate { page.view.alpha = 1 }
    }

    private func hideDetail() {
        guard let page = detail else { return }
        AuxMotion.animate { page.view.alpha = 0 } completion: {
            page.willMove(toParent: nil)
            page.view.removeFromSuperview()
            page.removeFromParent()
        }
        detail = nil
    }
}

@MainActor
final class PracticeDayCell: UITableViewCell {
    static let reuse = "PracticeDayCell"

    var onOpen: ((PracticeDay) -> Void)?
    private let open = UIButton(type: .custom)
    private let title = UILabel()
    private let meta = UILabel()
    private let seal = UILabel()
    private var day: PracticeDay?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = AuxColor.background

        open.translatesAutoresizingMaskIntoConstraints = false
        AuxElevation.apply(to: open)
        open.addTarget(self, action: #selector(openDay), for: .touchUpInside)
        open.configurationUpdateHandler = { button in
            button.alpha = button.isHighlighted ? 0.72 : 1
        }

        title.font = AuxType.body()
        title.textColor = AuxColor.ink
        title.adjustsFontForContentSizeCategory = true
        title.adjustsFontSizeToFitWidth = true
        title.isUserInteractionEnabled = false

        meta.font = AuxType.caption()
        meta.textColor = AuxColor.muted
        meta.adjustsFontForContentSizeCategory = true
        meta.isUserInteractionEnabled = false

        seal.translatesAutoresizingMaskIntoConstraints = false
        seal.font = AuxType.caption()
        seal.textColor = AuxColor.ink
        seal.textAlignment = .center
        seal.adjustsFontForContentSizeCategory = true
        seal.isUserInteractionEnabled = false
        AuxElevation.apply(to: seal, fill: AuxColor.accent.withAlphaComponent(0.22), radius: AuxRadius.chip)

        let stack = UIStackView(arrangedSubviews: [title, meta])
        stack.axis = .vertical
        stack.spacing = AuxSpace.unit
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isUserInteractionEnabled = false
        contentView.addSubview(open)
        open.addSubview(stack)
        open.addSubview(seal)

        NSLayoutConstraint.activate([
            open.topAnchor.constraint(equalTo: contentView.topAnchor, constant: AuxSpace.unit),
            open.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AuxSpace.step(2)),
            open.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AuxSpace.step(2)),
            open.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -AuxSpace.unit),
            open.heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),

            stack.leadingAnchor.constraint(equalTo: open.leadingAnchor, constant: AuxSpace.step(2)),
            stack.centerYAnchor.constraint(equalTo: open.centerYAnchor),
            stack.trailingAnchor.constraint(equalTo: seal.leadingAnchor, constant: -AuxSpace.step(1)),

            seal.trailingAnchor.constraint(equalTo: open.trailingAnchor, constant: -AuxSpace.step(2)),
            seal.centerYAnchor.constraint(equalTo: open.centerYAnchor),
            seal.widthAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.step(10)),
            seal.heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit / 2),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This row is built in code.")
    }

    func apply(_ day: PracticeDay) {
        self.day = day
        title.text = AuxFormat.day(day.dayKey)
        if day.isSealed {
            meta.text = "Sealed. \(AuxFormat.ringsOutOfSeven(day.ringCount))"
            seal.text = "Sealed"
            seal.isHidden = false
        } else {
            meta.text = "Partial. \(AuxFormat.ringsOutOfSeven(day.ringCount))"
            seal.text = ""
            seal.isHidden = true
        }
        open.accessibilityLabel = "\(title.text ?? ""), \(meta.text ?? "")"
    }

    @objc private func openDay() {
        guard let day else { return }
        onOpen?(day)
    }
}

/// Role: the selected day's rings under the Practices list so the sheet has no dead band.
@MainActor
final class PracticeDayPreview: UIView {
    private let mark = RingCountMark()
    private let title = UILabel()
    private let status = UILabel()
    private let row = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        AuxElevation.apply(to: self)

        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = AuxType.sectionTitle()
        title.textColor = AuxColor.ink
        title.adjustsFontForContentSizeCategory = true
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.7

        status.translatesAutoresizingMaskIntoConstraints = false
        status.font = AuxType.body()
        status.textColor = AuxColor.muted
        status.adjustsFontForContentSizeCategory = true
        status.numberOfLines = 2

        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = AuxSpace.unit
        row.alignment = .fill

        addSubview(mark)
        addSubview(title)
        addSubview(status)
        addSubview(row)
        NSLayoutConstraint.activate([
            mark.topAnchor.constraint(equalTo: topAnchor, constant: AuxSpace.step(2)),
            mark.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AuxSpace.step(2)),
            mark.widthAnchor.constraint(equalToConstant: AuxSpace.step(14)),
            mark.heightAnchor.constraint(equalToConstant: AuxSpace.step(14)),

            title.topAnchor.constraint(equalTo: mark.topAnchor),
            title.leadingAnchor.constraint(equalTo: mark.trailingAnchor, constant: AuxSpace.step(2)),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AuxSpace.step(2)),

            status.topAnchor.constraint(equalTo: title.bottomAnchor, constant: AuxSpace.unit),
            status.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            status.trailingAnchor.constraint(equalTo: title.trailingAnchor),

            row.topAnchor.constraint(equalTo: mark.bottomAnchor, constant: AuxSpace.step(2)),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AuxSpace.step(2)),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AuxSpace.step(2)),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AuxSpace.step(2)),
        ])
        isAccessibilityElement = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This preview is built in code.")
    }

    func apply(_ day: PracticeDay) {
        mark.apply(count: day.ringCount, sealed: day.isSealed)
        title.text = AuxFormat.day(day.dayKey)
        status.text = day.isSealed
            ? "Sealed. \(AuxFormat.ringsOutOfSeven(day.ringCount))"
            : "Partial. \(AuxFormat.ringsOutOfSeven(day.ringCount))"
        row.arrangedSubviews.forEach { view in
            row.removeArrangedSubview(view)
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
            row.addArrangedSubview(chip)
        }
        accessibilityLabel = "\(title.text ?? ""), \(status.text ?? "")"
    }
}
