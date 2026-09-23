import AuxCanvasCore
import AuxCanvasStore
import AuxRingKit
import UIKit

/// Role: contact, haptics, Reduce Motion note, version, replay, and a confirmed reset.
@MainActor
final class SettingsSheetViewController: UIViewController {
    var onReplayOnboarding: (() -> Void)?
    var onReset: (() -> Void)?

    private let store: AuxStore
    private let header = SheetHeaderView(title: "Settings")
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private let contact = AuxButton(title: "Contact Auxesis", kind: .primary)
    private let strata = AuxButton(title: "How rings ascend", kind: .secondary)
    private let replay = AuxButton(title: "Replay onboarding", kind: .secondary)
    private let reset = AuxButton(title: "Reset all data", kind: .destructive)
    private let haptics = UISegmentedControl(items: HapticIntensity.allCases.map(\.title))
    private let motionNote = UILabel()
    private let version = UILabel()
    private let emptyNote = UILabel()
    private let sealNote = UILabel()
    private let hapticKey = UILabel()
    private let canvasCard = SettingsCanvasCard()
    private let error: AuxEmptyState
    private var work: Task<Void, Never>?
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []

    init(store: AuxStore) {
        self.store = store
        error = AuxEmptyState(
            image: AuxAsset.image(AuxAsset.emptyList),
            headlineText: "Settings could not finish.",
            lineText: "The reset did not complete. Retry keeps the canvas on this device.",
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
        contact.addTarget(self, action: #selector(openContact), for: .touchUpInside)
        strata.addTarget(self, action: #selector(openStrata), for: .touchUpInside)
        replay.addTarget(self, action: #selector(replayOnboarding), for: .touchUpInside)
        reset.addTarget(self, action: #selector(confirmReset), for: .touchUpInside)
        error.actionButton.addTarget(self, action: #selector(confirmReset), for: .touchUpInside)
        error.isHidden = true

        haptics.selectedSegmentIndex = AuxPreferences.hapticStyle.rawValue
        haptics.backgroundColor = AuxColor.surface
        haptics.selectedSegmentTintColor = AuxColor.accent
        haptics.setTitleTextAttributes([.foregroundColor: AuxColor.ink, .font: AuxType.caption()], for: .normal)
        haptics.setTitleTextAttributes([.foregroundColor: AuxColor.background, .font: AuxType.caption()], for: .selected)
        haptics.addTarget(self, action: #selector(hapticsChanged), for: .valueChanged)
        haptics.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            haptics.heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
        ])

        motionNote.font = AuxType.body()
        motionNote.textColor = AuxColor.muted
        motionNote.numberOfLines = 0
        motionNote.adjustsFontForContentSizeCategory = true
        motionNote.text = UIAccessibility.isReduceMotionEnabled
            ? "Reduce Motion is on. Depth and travel stay still."
            : "The system Reduce Motion switch lives in iOS Settings."

        version.font = AuxType.caption()
        version.textColor = AuxColor.muted
        version.adjustsFontForContentSizeCategory = true
        let marketing = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        version.text = "Auxesis \(marketing)"

        emptyNote.font = AuxType.body()
        emptyNote.textColor = AuxColor.muted
        emptyNote.numberOfLines = 0
        emptyNote.adjustsFontForContentSizeCategory = true
        emptyNote.text = "Rings stay on this device. A reset clears every canvas."

        sealNote.font = AuxType.body()
        sealNote.textColor = AuxColor.muted
        sealNote.numberOfLines = 0
        sealNote.adjustsFontForContentSizeCategory = true
        sealNote.text = "Seven rings seal the day. After the seventh, the canvas stays read only."

        hapticKey.attributedText = AuxType.hairlineAttributed("Haptics", color: AuxColor.muted)
        hapticKey.adjustsFontForContentSizeCategory = true

        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.contentInset.bottom = AuxSpace.step(2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = AuxSpace.step(1)
        stack.alignment = .fill
        stack.distribution = .fill

        canvasCard.setContentHuggingPriority(.defaultLow, for: .vertical)
        canvasCard.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        [
            contact, hapticKey, haptics, motionNote, strata, replay, reset, emptyNote, sealNote, version, canvasCard,
        ].forEach(stack.addArrangedSubview)

        view.addSubview(header)
        view.addSubview(scroll)
        scroll.addSubview(stack)
        view.addSubview(error)

        let guide = view.safeAreaLayoutGuide
        let shared: [NSLayoutConstraint] = [
            header.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(1)),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuxSpace.step(2)),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuxSpace.step(2)),

            error.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AuxSpace.step(1)),
            error.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            error.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            error.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -AuxSpace.step(2)),
        ]

        compactConstraints = [
            scroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AuxSpace.step(1)),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuxSpace.step(2)),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuxSpace.step(2)),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            stack.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor, constant: -AuxSpace.step(2)),
        ]

        regularConstraints = [
            scroll.topAnchor.constraint(equalTo: header.bottomAnchor, constant: AuxSpace.step(1)),
            scroll.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scroll.widthAnchor.constraint(equalToConstant: AuxSpace.step(54)),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            stack.heightAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.heightAnchor, constant: -AuxSpace.step(2)),
        ]

        NSLayoutConstraint.activate(shared)
        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (screen: SettingsSheetViewController, _) in
            screen.applyLayoutTraits()
        }
        applyLayoutTraits()
        reloadCanvas()
    }

    private func applyLayoutTraits() {
        let regular = traitCollection.horizontalSizeClass == .regular
        NSLayoutConstraint.deactivate(compactConstraints)
        NSLayoutConstraint.deactivate(regularConstraints)
        stack.distribution = .fill
        NSLayoutConstraint.activate(regular ? regularConstraints : compactConstraints)
    }

    @objc private func close() {
        dismiss(animated: AuxMotion.shouldTravel)
    }

    @objc private func openContact() {
        guard let url = URL(string: "https://auxesis-ring.pro/contact-us") else { return }
        UIApplication.shared.open(url)
    }

    @objc private func openStrata() {
        let page = StrataSheetViewController(canvas: nil)
        page.modalPresentationStyle = .pageSheet
        if let sheet = page.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = AuxRadius.surface
        }
        present(page, animated: AuxMotion.shouldTravel)
    }

    @objc private func replayOnboarding() {
        onReplayOnboarding?()
    }

    @objc private func hapticsChanged() {
        let raw = haptics.selectedSegmentIndex
        AuxPreferences.setHapticStyle(HapticIntensity(rawValue: raw) ?? .medium)
    }

    @objc private func confirmReset() {
        let alert = UIAlertController(
            title: "Reset all data?",
            message: "Every canvas, ring, and seal on this device will be removed.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.runReset()
        })
        present(alert, animated: AuxMotion.shouldTravel)
    }

    private func runReset() {
        work?.cancel()
        work = Task { [weak self] in
            await self?.resetStore()
        }
    }

    private func resetStore() async {
        reset.isEnabled = false
        do {
            try await store.resetAllData()
            let today = DayKey.of(Date())
            _ = try await store.seedIfNeeded(dayKey: today, at: Date())
            error.isHidden = true
            emptyNote.isHidden = false
            emptyNote.text = "The store is empty. Today holds one thin ring again."
            reset.isEnabled = true
            reloadCanvas()
            onReset?()
        } catch {
            reset.isEnabled = true
            self.error.isHidden = false
        }
    }

    private func reloadCanvas() {
        work = Task { [weak self] in
            guard let self else { return }
            do {
                let today = try await self.store.seedIfNeeded(dayKey: DayKey.of(Date()), at: Date())
                self.canvasCard.apply(canvas: today)
            } catch {
                self.canvasCard.apply(canvas: nil)
            }
        }
    }
}

@MainActor
final class SettingsCanvasCard: UIView {
    private let tile = AuxTile()
    private let key = UILabel()
    private let value = UILabel()
    private let line = UILabel()
    private let track = DayRingTrackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        key.translatesAutoresizingMaskIntoConstraints = false
        key.attributedText = AuxType.hairlineAttributed("Today on this device", color: AuxColor.muted)
        key.adjustsFontForContentSizeCategory = true
        key.setContentHuggingPriority(.required, for: .vertical)

        value.translatesAutoresizingMaskIntoConstraints = false
        value.font = AuxType.canvasFigure()
        value.textColor = AuxColor.ink
        value.adjustsFontForContentSizeCategory = true
        value.adjustsFontSizeToFitWidth = true
        value.minimumScaleFactor = 0.6
        value.setContentHuggingPriority(.required, for: .vertical)

        line.translatesAutoresizingMaskIntoConstraints = false
        line.font = AuxType.body()
        line.textColor = AuxColor.ink
        line.numberOfLines = 0
        line.adjustsFontForContentSizeCategory = true
        line.setContentHuggingPriority(.required, for: .vertical)

        track.setContentHuggingPriority(.defaultLow, for: .vertical)
        track.setColumnAxis(.horizontal)

        addSubview(tile)
        tile.addSubview(key)
        tile.addSubview(value)
        tile.addSubview(line)
        tile.addSubview(track)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.step(22)),
            tile.topAnchor.constraint(equalTo: topAnchor),
            tile.leadingAnchor.constraint(equalTo: leadingAnchor),
            tile.trailingAnchor.constraint(equalTo: trailingAnchor),
            tile.bottomAnchor.constraint(equalTo: bottomAnchor),
            key.topAnchor.constraint(equalTo: tile.topAnchor, constant: AuxSpace.step(2)),
            key.leadingAnchor.constraint(equalTo: tile.leadingAnchor, constant: AuxSpace.step(2)),
            key.trailingAnchor.constraint(equalTo: tile.trailingAnchor, constant: -AuxSpace.step(2)),
            value.topAnchor.constraint(equalTo: key.bottomAnchor, constant: AuxSpace.unit),
            value.leadingAnchor.constraint(equalTo: key.leadingAnchor),
            value.trailingAnchor.constraint(equalTo: key.trailingAnchor),
            line.topAnchor.constraint(equalTo: value.bottomAnchor, constant: AuxSpace.unit),
            line.leadingAnchor.constraint(equalTo: key.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: key.trailingAnchor),
            track.topAnchor.constraint(equalTo: line.bottomAnchor, constant: AuxSpace.step(1)),
            track.leadingAnchor.constraint(equalTo: key.leadingAnchor),
            track.trailingAnchor.constraint(equalTo: key.trailingAnchor),
            track.bottomAnchor.constraint(equalTo: tile.bottomAnchor, constant: -AuxSpace.step(2)),
        ])
        isAccessibilityElement = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This settings canvas is built in code.")
    }

    func apply(canvas: AuxCanvasStrata?) {
        let count = canvas?.ringCount ?? 0
        value.text = AuxFormat.ringsOutOfSeven(count)
        if canvas?.isSealed == true {
            line.text = "Today is sealed. Seven rings hold the day on this device."
        } else {
            line.text = "Start the next ring from the canvas. Seven rings seal the day."
        }
        track.apply(rings: canvas?.rings ?? [])
        accessibilityLabel = "Today on this device, \(value.text ?? ""), \(line.text ?? "")"
    }
}
