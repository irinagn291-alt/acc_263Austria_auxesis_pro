import AuxCanvasCore
import AuxCanvasStore
import AuxRingKit
import UIKit

/// Role: the locked home surface. Owns the strata, the fused gestures, and the sheet chrome.
@MainActor
final class CanvasViewController: UIViewController {
    var onReplayOnboarding: (() -> Void)?

    private let store: AuxStore
    private var canvas = AuxCanvasStrata.empty(dayKey: DayKey.of(Date()))
    private var loadTask: Task<Void, Never>?
    private var foldTask: Task<Void, Never>?
    private var didApplyReview = false
    private var guidedScale: CGFloat = 1
    private var pendingDragSeconds: Int?
    private var startingRound = false
    private var lastHoldFoldMillis = 0
    private var lastHapticMillis = 0

    private let titleLabel = UILabel()
    private let job = UILabel()
    private let countTile = FactTileButton()
    private let floorTile = FactTileButton()
    private let track = DayRingTrackView()
    private let history = RoundHistoryView()
    private let renderer = RingStrataLayerRenderer()
    private let circle = CenterCircleControl()
    private let primary = AuxButton(title: "Start round", kind: .primary)
    private let caption = UILabel()
    private let banner = RefusalBanner()
    private let success = UIImageView()
    private let chrome = CanvasChromeBar()
    private let errorState: AuxEmptyState
    private let haptics = PaceHapticDriver()
    private let ticker = GuidedCycleTicker()
    private let canvasPlate = AuxTile()
    private let leftPane = UIView()
    private let rightPane = UIView()
    private let rail = UIStackView()
    private var layoutConstraints: [NSLayoutConstraint] = []

    init(store: AuxStore) {
        self.store = store
        errorState = AuxEmptyState(
            image: AuxAsset.image(AuxAsset.emptyHome),
            headlineText: "Today's canvas did not load.",
            lineText: "The rings stay on this device. Retry opens the store again.",
            actionTitle: "Retry"
        )
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This screen is built in code.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AuxColor.background
        buildHierarchy()
        bindActions()
        errorState.isHidden = true
        applyLayoutTraits()
        reloadToday()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dayMayHaveChanged),
            name: UIApplication.significantTimeChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dayMayHaveChanged),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(motionMayHaveChanged),
            name: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil
        )
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self, UITraitHorizontalSizeClass.self]) { (screen: CanvasViewController, _) in
            screen.countTile.refreshFigureFont(compatibleWith: screen.traitCollection)
            screen.floorTile.refreshFigureFont(compatibleWith: screen.traitCollection)
            screen.applyLayoutTraits()
            screen.render()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyReviewKeysIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        renderer.render(rings: canvas.rings, sealed: canvas.isSealed, guidedScale: guidedScale)
    }

    func prepareReviewKeysAfterOnboarding() {
        applyReviewKeysIfNeeded()
    }

    /// Reads `-ReviewScreen` once, after onboarding. Keys are launch arguments, not tabs.
    func applyReviewKeysIfNeeded() {
        guard AuxPreferences.isOnboardingComplete, view.window != nil, !didApplyReview else { return }
        didApplyReview = true
        let arguments = ProcessInfo.processInfo.arguments
        guard arguments.contains("-ReviewScreen") else { return }
        guard let key = ReviewScreenKeys.parse(arguments: arguments) else { return }
        switch key {
        case .today:
            break
        case .log:
            presentPractices()
        case .goals:
            presentStats()
        case .settings:
            presentSettings()
        case .strata:
            presentStrata()
        }
    }

    func reloadAfterReset() {
        reloadToday()
    }

    private func buildHierarchy() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Auxesis"
        titleLabel.font = AuxType.sectionTitle()
        titleLabel.textColor = AuxColor.ink
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .left
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        job.translatesAutoresizingMaskIntoConstraints = false
        job.text = "A ring is one breath round. Seven rings seal the day."
        job.font = AuxType.body()
        job.textColor = AuxColor.ink
        job.numberOfLines = 2
        job.textAlignment = .left
        job.adjustsFontForContentSizeCategory = true
        job.adjustsFontSizeToFitWidth = true
        job.minimumScaleFactor = 0.7
        job.setContentHuggingPriority(.required, for: .vertical)
        job.setContentCompressionResistancePriority(.required, for: .vertical)

        countTile.apply(key: "Rings today", value: AuxFormat.ringsOutOfSeven(0))
        countTile.accessibilityHint = "Opens how rings grow."
        floorTile.apply(key: "Shortest round", value: AuxFormat.minutes(RoundDuration.minimumSeconds))
        floorTile.accessibilityHint = "Opens how rings grow."

        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.font = AuxType.body()
        caption.textColor = AuxColor.ink
        caption.numberOfLines = 2
        caption.adjustsFontForContentSizeCategory = true
        caption.textAlignment = .left

        success.translatesAutoresizingMaskIntoConstraints = false
        success.image = AuxAsset.image(AuxAsset.successMark)
        success.contentMode = .scaleAspectFit
        success.alpha = 0
        success.isAccessibilityElement = false

        canvasPlate.translatesAutoresizingMaskIntoConstraints = false
        canvasPlate.clipsToBounds = true
        leftPane.translatesAutoresizingMaskIntoConstraints = false
        rightPane.translatesAutoresizingMaskIntoConstraints = false

        rail.translatesAutoresizingMaskIntoConstraints = false
        rail.axis = .vertical
        rail.spacing = AuxSpace.step(1)
        rail.alignment = .fill
        history.setContentHuggingPriority(.defaultLow, for: .vertical)
        history.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        countTile.setContentHuggingPriority(.defaultLow, for: .horizontal)
        floorTile.setContentHuggingPriority(.required, for: .horizontal)

        errorState.translatesAutoresizingMaskIntoConstraints = false
        errorState.actionButton.addTarget(self, action: #selector(reloadToday), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(job)
        view.addSubview(leftPane)
        view.addSubview(rightPane)
        view.addSubview(chrome)
        view.addSubview(errorState)

        leftPane.addSubview(canvasPlate)
        canvasPlate.addSubview(renderer.host)
        canvasPlate.addSubview(circle)
        canvasPlate.addSubview(success)

        renderer.attachParallax()
    }

    private func applyLayoutTraits() {
        let regular = traitCollection.horizontalSizeClass == .regular
        NSLayoutConstraint.deactivate(layoutConstraints)
        track.removeFromSuperview()
        rail.removeFromSuperview()
        history.removeFromSuperview()
        caption.removeFromSuperview()
        countTile.removeFromSuperview()
        floorTile.removeFromSuperview()
        primary.removeFromSuperview()
        banner.removeFromSuperview()
        rail.arrangedSubviews.forEach { view in
            rail.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        titleLabel.removeFromSuperview()
        job.removeFromSuperview()
        renderer.host.clipsToBounds = true

        let guide = view.safeAreaLayoutGuide
        var next: [NSLayoutConstraint] = [
            chrome.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            chrome.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),
            chrome.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -AuxSpace.step(1)),

            canvasPlate.topAnchor.constraint(equalTo: leftPane.topAnchor),
            canvasPlate.leadingAnchor.constraint(equalTo: leftPane.leadingAnchor),
            canvasPlate.trailingAnchor.constraint(equalTo: leftPane.trailingAnchor),
            canvasPlate.bottomAnchor.constraint(equalTo: leftPane.bottomAnchor),

            renderer.host.leadingAnchor.constraint(equalTo: canvasPlate.leadingAnchor, constant: AuxSpace.unit),
            renderer.host.trailingAnchor.constraint(equalTo: canvasPlate.trailingAnchor, constant: -AuxSpace.unit),

            circle.centerXAnchor.constraint(equalTo: renderer.host.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: renderer.host.centerYAnchor),
            circle.widthAnchor.constraint(equalTo: renderer.host.widthAnchor, multiplier: 0.38),
            circle.heightAnchor.constraint(equalTo: circle.widthAnchor),

            success.centerXAnchor.constraint(equalTo: renderer.host.centerXAnchor),
            success.centerYAnchor.constraint(equalTo: renderer.host.centerYAnchor),
            success.widthAnchor.constraint(equalToConstant: AuxSpace.step(10)),
            success.heightAnchor.constraint(equalToConstant: AuxSpace.step(10)),

            errorState.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(2)),
            errorState.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
            errorState.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),
            errorState.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -AuxSpace.step(2)),
        ]

        if regular {
            leftPane.addSubview(titleLabel)
            leftPane.addSubview(job)
            canvasPlate.addSubview(track)
            canvasPlate.addSubview(caption)
            leftPane.bringSubviewToFront(titleLabel)
            leftPane.bringSubviewToFront(job)
            rightPane.addSubview(countTile)
            rightPane.addSubview(floorTile)
            rightPane.addSubview(rail)
            rail.addArrangedSubview(primary)
            rail.addArrangedSubview(banner)
            rail.addArrangedSubview(history)
            history.isHidden = false
            track.setColumnAxis(.horizontal)
            track.isHidden = false
            next += [
                leftPane.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(1)),
                leftPane.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
                leftPane.bottomAnchor.constraint(equalTo: chrome.topAnchor, constant: -AuxSpace.step(1)),
                leftPane.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.48),

                titleLabel.topAnchor.constraint(equalTo: leftPane.topAnchor, constant: AuxSpace.step(2)),
                titleLabel.leadingAnchor.constraint(equalTo: leftPane.leadingAnchor, constant: AuxSpace.step(2)),
                titleLabel.trailingAnchor.constraint(equalTo: leftPane.trailingAnchor, constant: -AuxSpace.step(2)),

                job.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: AuxSpace.unit),
                job.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                job.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

                renderer.host.topAnchor.constraint(equalTo: canvasPlate.topAnchor, constant: AuxSpace.step(10)),
                {
                    let square = renderer.host.heightAnchor.constraint(equalTo: renderer.host.widthAnchor)
                    square.priority = .defaultHigh
                    return square
                }(),

                track.topAnchor.constraint(equalTo: renderer.host.bottomAnchor, constant: AuxSpace.unit),
                track.leadingAnchor.constraint(equalTo: canvasPlate.leadingAnchor, constant: AuxSpace.step(2)),
                track.trailingAnchor.constraint(equalTo: canvasPlate.trailingAnchor, constant: -AuxSpace.step(2)),

                caption.topAnchor.constraint(equalTo: track.bottomAnchor, constant: AuxSpace.unit),
                caption.leadingAnchor.constraint(equalTo: track.leadingAnchor),
                caption.trailingAnchor.constraint(equalTo: track.trailingAnchor),
                caption.bottomAnchor.constraint(equalTo: canvasPlate.bottomAnchor, constant: -AuxSpace.step(2)),

                rightPane.topAnchor.constraint(equalTo: leftPane.topAnchor),
                rightPane.leadingAnchor.constraint(equalTo: leftPane.trailingAnchor, constant: AuxSpace.step(1)),
                rightPane.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),
                rightPane.bottomAnchor.constraint(equalTo: leftPane.bottomAnchor),

                countTile.topAnchor.constraint(equalTo: rightPane.topAnchor),
                countTile.leadingAnchor.constraint(equalTo: rightPane.leadingAnchor),
                countTile.widthAnchor.constraint(equalTo: rightPane.widthAnchor, multiplier: 0.62),
                countTile.heightAnchor.constraint(equalToConstant: AuxSpace.step(12)),

                floorTile.topAnchor.constraint(equalTo: countTile.topAnchor),
                floorTile.leadingAnchor.constraint(equalTo: countTile.trailingAnchor, constant: AuxSpace.unit),
                floorTile.trailingAnchor.constraint(equalTo: rightPane.trailingAnchor),
                floorTile.heightAnchor.constraint(equalTo: countTile.heightAnchor),

                rail.topAnchor.constraint(equalTo: countTile.bottomAnchor, constant: AuxSpace.unit),
                rail.leadingAnchor.constraint(equalTo: rightPane.leadingAnchor),
                rail.trailingAnchor.constraint(equalTo: rightPane.trailingAnchor),
                rail.bottomAnchor.constraint(equalTo: rightPane.bottomAnchor),
            ]
        } else {
            view.addSubview(titleLabel)
            view.addSubview(job)
            view.addSubview(countTile)
            view.addSubview(floorTile)
            rightPane.addSubview(history)
            rightPane.addSubview(rail)
            rail.addArrangedSubview(primary)
            rail.addArrangedSubview(caption)
            rail.addArrangedSubview(banner)
            history.isHidden = false
            let canvasHeight = leftPane.heightAnchor.constraint(equalTo: leftPane.widthAnchor, multiplier: 0.62)
            canvasHeight.priority = .defaultHigh
            next += [
                titleLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: AuxSpace.step(1)),
                titleLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: AuxSpace.step(2)),
                titleLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -AuxSpace.step(2)),

                job.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: AuxSpace.unit),
                job.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                job.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

                leftPane.topAnchor.constraint(equalTo: job.bottomAnchor, constant: AuxSpace.unit),
                leftPane.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                leftPane.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                leftPane.heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.step(20)),
                canvasHeight,

                renderer.host.topAnchor.constraint(equalTo: canvasPlate.topAnchor, constant: AuxSpace.unit),
                renderer.host.bottomAnchor.constraint(equalTo: canvasPlate.bottomAnchor, constant: -AuxSpace.unit),

                countTile.topAnchor.constraint(equalTo: leftPane.bottomAnchor, constant: AuxSpace.unit),
                countTile.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                countTile.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.58),
                countTile.heightAnchor.constraint(equalToConstant: AuxSpace.step(11)),

                floorTile.topAnchor.constraint(equalTo: countTile.topAnchor),
                floorTile.leadingAnchor.constraint(equalTo: countTile.trailingAnchor, constant: AuxSpace.unit),
                floorTile.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                floorTile.heightAnchor.constraint(equalTo: countTile.heightAnchor),

                rightPane.topAnchor.constraint(equalTo: countTile.bottomAnchor, constant: AuxSpace.unit),
                rightPane.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                rightPane.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                rightPane.bottomAnchor.constraint(equalTo: chrome.topAnchor, constant: -AuxSpace.step(1)),

                history.topAnchor.constraint(equalTo: rightPane.topAnchor),
                history.leadingAnchor.constraint(equalTo: rightPane.leadingAnchor),
                history.trailingAnchor.constraint(equalTo: rightPane.trailingAnchor),

                rail.topAnchor.constraint(equalTo: history.bottomAnchor, constant: AuxSpace.unit),
                rail.leadingAnchor.constraint(equalTo: rightPane.leadingAnchor),
                rail.trailingAnchor.constraint(equalTo: rightPane.trailingAnchor),
                rail.bottomAnchor.constraint(equalTo: rightPane.bottomAnchor),
            ]
        }

        layoutConstraints = next
        NSLayoutConstraint.activate(layoutConstraints)
    }

    private func bindActions() {
        circle.onPressBegan = { [weak self] millis in
            self?.handlePress(millis)
        }
        circle.onPressHold = { [weak self] millis in
            self?.handleHold(millis)
        }
        circle.onPressEnded = { [weak self] millis in
            self?.haptics.stop()
            self?.handleHold(millis)
        }
        circle.onDrag = { [weak self] upward in
            self?.previewDrag(upward)
        }
        circle.onSwipe = { [weak self] upward in
            self?.handleSwipe(upward)
        }
        circle.onTap = { [weak self] in
            self?.startRoundFromControl()
        }
        primary.addTarget(self, action: #selector(startRoundFromControl), for: .touchUpInside)
        history.onOpen = { [weak self] in
            self?.presentPractices()
        }
        countTile.addTarget(self, action: #selector(presentStrata), for: .touchUpInside)
        floorTile.addTarget(self, action: #selector(presentStrata), for: .touchUpInside)
        chrome.practices.addTarget(self, action: #selector(presentPractices), for: .touchUpInside)
        chrome.stats.addTarget(self, action: #selector(presentStats), for: .touchUpInside)
        chrome.settings.addTarget(self, action: #selector(presentSettings), for: .touchUpInside)
        ticker.onPhase = { [weak self] phase, progress in
            self?.applyGuided(phase: phase, progress: progress)
        }
        ticker.onComplete = { [weak self] in
            self?.finishExhale()
        }
    }

    @objc private func reloadToday() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadToday()
        }
    }

    @objc private func dayMayHaveChanged() {
        let today = DayKey.of(Date())
        if today != canvas.dayKey {
            reloadToday()
        }
    }

    @objc private func motionMayHaveChanged() {
        renderer.attachParallax()
        render()
    }

    private func loadToday() async {
        do {
            let today = DayKey.of(Date())
            let seeded = try await store.seedIfNeeded(dayKey: today, at: Date())
            canvas = seeded
            errorState.isHidden = true
            render()
        } catch {
            errorState.isHidden = false
        }
    }

    private func handlePress(_ millis: Int) {
        guard !canvas.isSealed else {
            banner.show(RefusalCopy.line(for: .canvasSealed))
            haptics.warn()
            return
        }
        lastHoldFoldMillis = millis
        lastHapticMillis = millis
        haptics.start(intervalMillis: millis)
        fold(.press(holdMillis: millis))
    }

    private func handleHold(_ millis: Int) {
        guard !canvas.isSealed, canvas.phase != .guided else { return }
        if abs(millis - lastHapticMillis) >= 50 {
            lastHapticMillis = millis
            haptics.retune(intervalMillis: millis)
        }
        if millis >= PaceHold.minimumPressMillis, abs(millis - lastHoldFoldMillis) >= 80 {
            lastHoldFoldMillis = millis
            fold(.press(holdMillis: millis))
        }
        if pendingDragSeconds == nil {
            caption.text = "Pace \(AuxFormat.pace(millis)). Swipe up to set the span."
        }
    }

    private func previewDrag(_ upward: Double) {
        guard canvas.phase == .pacing || canvas.phase == .guided else { return }
        let seconds = DragSpan.seconds(upwardPoints: upward)
        pendingDragSeconds = seconds
        caption.text = "Span \(AuxFormat.minutes(seconds)). Release to begin."
    }

    private func handleSwipe(_ upward: Double) {
        guard canvas.phase != .guided else { return }
        let seconds = DragSpan.seconds(upwardPoints: upward)
        pendingDragSeconds = seconds
        if upward < AuxSpace.step(3) {
            render()
            return
        }
        fold(.swipe(durationSeconds: seconds))
    }

    @objc private func startRoundFromControl() {
        if canvas.isSealed {
            banner.show(RefusalCopy.line(for: .canvasSealed))
            return
        }
        if canvas.phase == .guided {
            ticker.stop()
            fold(.abandon)
            return
        }
        guard !startingRound else { return }
        startingRound = true
        foldTask = Task { [weak self] in
            await self?.beginGuidedRound()
            self?.startingRound = false
        }
    }

    private func beginGuidedRound() async {
        if canvas.phase == .idle {
            await apply(.press(holdMillis: PaceHold.minimumPressMillis))
            if canvas.phase != .pacing { return }
        }
        let seconds = canvas.outermostDuration?.seconds ?? RoundDuration.minimumSeconds
        await apply(.swipe(durationSeconds: seconds))
    }

    private func finishExhale() {
        fold(.completeExhale)
    }

    private func fold(_ event: CanvasEvent) {
        foldTask = Task { [weak self] in
            await self?.apply(event)
        }
    }

    private func apply(_ event: CanvasEvent) async {
        do {
            let result = try await store.apply(event, on: canvas.dayKey, at: Date())
            if let refusal = result.refusal {
                banner.show(RefusalCopy.line(for: refusal))
                haptics.warn()
                render()
                return
            }
            canvas = result.canvas
            if result.writtenLayer != nil {
                haptics.commit()
                flashSuccess()
            }
            if canvas.phase == .guided, let round = canvas.guided {
                ticker.start(round: round)
            } else if event == .abandon || result.writtenLayer != nil {
                ticker.stop()
                guidedScale = 1
                circle.setGuidedScale(1)
            }
            render()
        } catch let fault as AuxStoreError where fault == .canvasSealed {
            banner.show(RefusalCopy.line(for: .canvasSealed))
            haptics.warn()
        } catch {
            errorState.isHidden = false
        }
    }

    private func applyGuided(phase: GuidedPhase, progress: Double) {
        let from = phase.scaleFrom
        let to = phase.scaleTo
        let scale = from + (to - from) * progress
        guidedScale = CGFloat(scale)
        circle.setGuidedScale(guidedScale)
        renderer.render(rings: canvas.rings, sealed: canvas.isSealed, guidedScale: guidedScale)
        switch phase {
        case .inhale:
            caption.text = "Inhale."
            circle.setVerb("Inhale")
        case .hold:
            caption.text = "Hold."
            circle.setVerb("Hold")
        case .exhale:
            caption.text = "Exhale."
            circle.setVerb("Exhale")
        }
        var next = canvas
        if var guided = next.guided {
            guided.phase = phase
            next.guided = guided
            canvas = next
        }
    }

    private func render() {
        let count = canvas.ringCount
        countTile.apply(key: "Rings today", value: AuxFormat.ringsOutOfSeven(count))
        let floor = canvas.outermostDuration?.seconds ?? RoundDuration.minimumSeconds
        floorTile.apply(key: "Outer floor", value: AuxFormat.minutes(floor))
        track.apply(rings: canvas.rings)
        history.apply(rings: canvas.rings)
        circle.isEnabled = !canvas.isSealed
        circle.setProgress(rings: count, of: FullMarkSeal.ringCapacity)
        renderer.render(rings: canvas.rings, sealed: canvas.isSealed, guidedScale: guidedScale)
        if canvas.isSealed {
            caption.text = "Today is sealed. Seven rings hold the day."
            primary.setTitleText("Day sealed")
            primary.isEnabled = false
            circle.setVerb(AuxFormat.ringsOutOfSeven(count))
        } else if canvas.phase == .guided {
            primary.setTitleText("End round")
            primary.isEnabled = true
            caption.text = caption.text ?? "Inhale."
        } else if canvas.phase == .pacing {
            primary.setTitleText("Start round")
            primary.isEnabled = true
            circle.setVerb(AuxFormat.ringsOutOfSeven(count))
            let pace = canvas.pendingPace?.millis ?? PaceHold.minimumPressMillis
            caption.text = "Pace \(AuxFormat.pace(pace)). Next ring \(AuxFormat.minutes(floor)) or longer."
        } else {
            primary.setTitleText("Start round")
            primary.isEnabled = true
            circle.setVerb(AuxFormat.ringsOutOfSeven(count))
            caption.text = "Start round files the next ring. Long press sets your own pace."
        }
        circle.accessibilityValue = canvas.isSealed ? "Sealed" : caption.text
    }

    private func flashSuccess() {
        success.alpha = 1
        AuxMotion.animate { self.success.alpha = 0 }
    }

    @objc private func presentPractices() {
        presentSheet(PracticesSheetViewController(store: store), large: true)
    }

    @objc private func presentStats() {
        presentSheet(StatsSheetViewController(store: store), large: false)
    }

    @objc private func presentSettings() {
        let settings = SettingsSheetViewController(store: store)
        settings.onReplayOnboarding = { [weak self] in
            self?.dismiss(animated: AuxMotion.shouldTravel) {
                self?.onReplayOnboarding?()
            }
        }
        settings.onReset = { [weak self] in
            self?.reloadAfterReset()
        }
        if traitCollection.horizontalSizeClass == .regular {
            settings.modalPresentationStyle = .formSheet
            settings.preferredContentSize = CGSize(width: AuxSpace.step(56), height: AuxSpace.step(78))
            present(settings, animated: AuxMotion.shouldTravel)
        } else {
            presentSheet(settings, large: false)
        }
    }

    @objc private func presentStrata() {
        presentSheet(StrataSheetViewController(canvas: canvas), large: true)
    }

    private func presentSheet(_ controller: UIViewController, large: Bool) {
        controller.modalPresentationStyle = .pageSheet
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [large ? .large() : .medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = AuxRadius.surface
        }
        present(controller, animated: AuxMotion.shouldTravel)
    }
}
