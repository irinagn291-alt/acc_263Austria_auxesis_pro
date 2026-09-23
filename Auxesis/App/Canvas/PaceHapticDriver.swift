import AuxRingKit
import UIKit

/// Role: inhale and exhale pulses while the finger is down during Pacing.
@MainActor
final class PaceHapticDriver {
    private var timer: Timer?
    private var generator: UIImpactFeedbackGenerator?

    func start(intervalMillis: Int) {
        stop()
        guard let style = Self.feedbackStyle() else { return }
        let interval = TimeInterval(max(PaceHoldGate.minimumMillis, intervalMillis)) / 1000
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        self.generator = generator
        generator.impactOccurred(intensity: 0.85)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.generator?.impactOccurred(intensity: 0.85)
            }
        }
    }

    func retune(intervalMillis: Int) {
        guard timer != nil else {
            start(intervalMillis: intervalMillis)
            return
        }
        start(intervalMillis: intervalMillis)
    }

    func commit() {
        guard Self.feedbackStyle() != nil else { return }
        let note = UINotificationFeedbackGenerator()
        note.notificationOccurred(.success)
    }

    func warn() {
        guard Self.feedbackStyle() != nil else { return }
        let note = UINotificationFeedbackGenerator()
        note.notificationOccurred(.warning)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        generator = nil
    }

    private static func feedbackStyle() -> UIImpactFeedbackGenerator.FeedbackStyle? {
        switch AuxPreferences.hapticStyle {
        case .off: nil
        case .light: .light
        case .medium: .medium
        case .heavy: .heavy
        }
    }
}

private enum PaceHoldGate {
    static let minimumMillis = 600
}
