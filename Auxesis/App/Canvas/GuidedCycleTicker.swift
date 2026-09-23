import AuxCanvasCore
import UIKit

/// Role: drives inhale, hold, and exhale at the held pace until the final exhale.
@MainActor
final class GuidedCycleTicker {
    var onPhase: ((GuidedPhase, Double) -> Void)?
    var onComplete: (() -> Void)?

    private var timer: Timer?
    private var startedAt: Date?
    private var duration: TimeInterval = 0
    private var pace: TimeInterval = 1
    private var pattern: BreathPattern = .calm
    private var completed = false

    func start(round: GuidedRound) {
        stop()
        completed = false
        pace = TimeInterval(max(1, round.pace.millis)) / 1000
        duration = TimeInterval(round.duration.seconds)
        pattern = round.pattern
        startedAt = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.frame()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        startedAt = nil
    }

    private func frame() {
        guard let startedAt, !completed else { return }
        let elapsed = Date().timeIntervalSince(startedAt)
        let inhale = TimeInterval(pattern.inhaleBeats) * pace
        let hold = TimeInterval(pattern.holdBeats) * pace
        let exhale = TimeInterval(pattern.exhaleBeats) * pace
        let cycle = inhale + hold + exhale
        guard cycle > 0 else { return }

        if elapsed >= duration {
            let remainder = elapsed.truncatingRemainder(dividingBy: cycle)
            if remainder >= inhale + hold, remainder >= cycle - 0.05 || elapsed >= duration + exhale {
                completed = true
                stop()
                onComplete?()
                return
            }
        }

        let t = elapsed.truncatingRemainder(dividingBy: cycle)
        let phase: GuidedPhase
        let progress: Double
        if t < inhale {
            phase = .inhale
            progress = inhale > 0 ? t / inhale : 1
        } else if t < inhale + hold {
            phase = .hold
            progress = hold > 0 ? (t - inhale) / hold : 1
        } else {
            phase = .exhale
            progress = exhale > 0 ? (t - inhale - hold) / exhale : 1
        }
        onPhase?(phase, min(1, max(0, progress)))
    }
}
