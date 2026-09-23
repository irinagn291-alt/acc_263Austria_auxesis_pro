import AuxCanvasStore
import AuxRingKit
import UIKit

/// Role: composition root. Opens the store, seeds on Simulator, then yields the canvas.
@MainActor
final class LaunchViewController: UIViewController {
    private var bootTask: Task<Void, Never>?
    private var store: AuxStore?
    private let spinner = UIActivityIndicatorView(style: .large)
    private var empty: AuxEmptyState?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AuxColor.background
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = AuxColor.accent
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        bootTask = Task { [weak self] in
            await self?.boot()
        }
    }

    private func boot() async {
        let spin = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            spinner.startAnimating()
        }
        do {
            let store = try await AuxStore.open(inMemory: false)
            try await DemoSeed.applyIfNeeded(store: store)
            self.store = store
            spin.cancel()
            spinner.stopAnimating()
            route(store: store)
        } catch {
            spin.cancel()
            spinner.stopAnimating()
            showError()
        }
    }

    private func route(store: AuxStore) {
        if AuxPreferences.isOnboardingComplete {
            showCanvas(store: store, applyReview: true)
        } else {
            showOnboarding(store: store)
        }
    }

    private func showOnboarding(store: AuxStore) {
        let onboarding = OnboardingViewController()
        onboarding.onFinished = { [weak self] in
            AuxPreferences.markOnboardingComplete()
            self?.showCanvas(store: store, applyReview: false)
        }
        embed(onboarding)
    }

    private func showCanvas(store: AuxStore, applyReview: Bool) {
        let canvas = CanvasViewController(store: store)
        canvas.onReplayOnboarding = { [weak self] in
            self?.showOnboarding(store: store)
        }
        embed(canvas)
        if applyReview {
            canvas.prepareReviewKeysAfterOnboarding()
        }
    }

    private func showError() {
        empty?.removeFromSuperview()
        let state = AuxEmptyState(
            image: AuxAsset.image(AuxAsset.emptyHome),
            headlineText: "The canvas could not open.",
            lineText: "The local store failed to load. Retry keeps everything on this device.",
            actionTitle: "Retry"
        )
        state.actionButton.addTarget(self, action: #selector(retry), for: .touchUpInside)
        view.addSubview(state)
        NSLayoutConstraint.activate([
            state.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AuxSpace.step(2)),
            state.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: AuxSpace.step(2)),
            state.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -AuxSpace.step(2)),
            state.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -AuxSpace.step(2)),
        ])
        empty = state
    }

    @objc private func retry() {
        empty?.removeFromSuperview()
        empty = nil
        if Date.distantPast.timeIntervalSinceNow < 0 {
            spinner.startAnimating()
        }
        bootTask?.cancel()
        bootTask = Task { [weak self] in
            await self?.boot()
        }
    }

    private func embed(_ child: UIViewController) {
        children.forEach { existing in
            existing.willMove(toParent: nil)
            existing.view.removeFromSuperview()
            existing.removeFromParent()
        }
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.alpha = 0
        view.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        child.didMove(toParent: self)
        AuxMotion.animate { child.view.alpha = 1 }
    }
}
