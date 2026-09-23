import AuxCanvasCore
import AuxRingKit
import UIKit

/// Role: fused long-press and swipe on the breath circle. Progress lives on this outline.
@MainActor
final class CenterCircleControl: UIControl, UIGestureRecognizerDelegate {
    var onPressBegan: ((Int) -> Void)?
    var onPressHold: ((Int) -> Void)?
    var onPressEnded: ((Int) -> Void)?
    var onDrag: ((Double) -> Void)?
    var onSwipe: ((Double) -> Void)?
    var onTap: (() -> Void)?

    private let verb = UILabel()
    private let track = CAShapeLayer()
    private let progress = CAShapeLayer()
    private let press = UILongPressGestureRecognizer()
    private let pan = UIPanGestureRecognizer()
    private let tap = UITapGestureRecognizer()
    private var pressStartedAt: Date?
    private var holdClock: Timer?
    private var progressValue: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        AuxElevation.apply(to: self, fill: AuxColor.background, radius: AuxRadius.surface)
        clipsToBounds = true
        isEnabled = true

        track.fillColor = UIColor.clear.cgColor
        track.strokeColor = AuxColor.muted.withAlphaComponent(0.45).cgColor
        track.lineWidth = 10
        track.lineCap = .round
        layer.addSublayer(track)

        progress.fillColor = UIColor.clear.cgColor
        progress.strokeColor = AuxColor.accent.cgColor
        progress.lineWidth = 10
        progress.lineCap = .round
        progress.strokeEnd = 0
        layer.addSublayer(progress)

        verb.translatesAutoresizingMaskIntoConstraints = false
        verb.text = AuxFormat.ringsOutOfSeven(0)
        verb.font = AuxType.body()
        verb.textColor = AuxColor.ink
        verb.textAlignment = .center
        verb.adjustsFontForContentSizeCategory = true
        verb.adjustsFontSizeToFitWidth = true
        verb.minimumScaleFactor = 0.6
        verb.numberOfLines = 2
        verb.isUserInteractionEnabled = false
        addSubview(verb)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
            heightAnchor.constraint(greaterThanOrEqualToConstant: AuxSpace.hit),
            verb.centerXAnchor.constraint(equalTo: centerXAnchor),
            verb.centerYAnchor.constraint(equalTo: centerYAnchor),
            verb.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: AuxSpace.step(2)),
            verb.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -AuxSpace.step(2)),
        ])

        isExclusiveTouch = true
        press.minimumPressDuration = TimeInterval(PaceHold.minimumPressMillis) / 1000
        press.allowableMovement = 80
        press.addTarget(self, action: #selector(handlePress(_:)))
        press.delegate = self
        addGestureRecognizer(press)

        pan.addTarget(self, action: #selector(handlePan(_:)))
        pan.delegate = self
        addGestureRecognizer(pan)

        tap.addTarget(self, action: #selector(handleTap))
        tap.delegate = self
        addGestureRecognizer(tap)

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "Start round"
        accessibilityHint = "Starts the next ring. Long press sets the pace, then swipe sets the span."
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This control is built in code.")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        let inset = progress.lineWidth / 2 + 2
        let radius = min(bounds.width, bounds.height) / 2 - inset
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: -.pi / 2 + .pi * 2,
            clockwise: true
        ).cgPath
        track.path = path
        progress.path = path
        progress.strokeEnd = progressValue
    }

    func setVerb(_ text: String) {
        verb.text = text
        accessibilityValue = text
    }

    func setProgress(rings: Int, of capacity: Int) {
        let total = max(capacity, 1)
        progressValue = CGFloat(min(max(rings, 0), total)) / CGFloat(total)
        progress.strokeEnd = progressValue
    }

    func setGuidedScale(_ scale: CGFloat) {
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        if AuxMotion.shouldTravel {
            verb.transform = transform
        } else {
            verb.transform = .identity
        }
    }

    func setPressed(_ pressed: Bool) {
        AuxMotion.animate {
            self.alpha = pressed ? 0.86 : 1
            if AuxMotion.shouldTravel {
                self.transform = pressed ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            }
        }
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pressStartedAt == nil {
            pressStartedAt = Date()
        }
        super.touchesBegan(touches, with: event)
    }

    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if pressStartedAt == nil {
                pressStartedAt = Date().addingTimeInterval(-TimeInterval(PaceHold.minimumPressMillis) / 1000)
            }
            setPressed(true)
            startHoldClock()
            onPressBegan?(elapsedMillis())
        case .changed:
            onPressHold?(elapsedMillis())
        case .ended, .cancelled:
            let held = elapsedMillis()
            stopHoldClock()
            setPressed(false)
            onPressEnded?(held)
            pressStartedAt = nil
        default:
            break
        }
    }

    private func startHoldClock() {
        stopHoldClock()
        holdClock = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.pressStartedAt != nil else { return }
                self.onPressHold?(self.elapsedMillis())
            }
        }
    }

    private func stopHoldClock() {
        holdClock?.invalidate()
        holdClock = nil
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let upward = Double(-gesture.translation(in: self).y)
        switch gesture.state {
        case .changed:
            onDrag?(upward)
        case .ended, .cancelled:
            onSwipe?(upward)
        default:
            break
        }
    }

    @objc private func handleTap() {
        onTap?()
    }

    private func elapsedMillis() -> Int {
        guard let pressStartedAt else { return PaceHold.minimumPressMillis }
        return Int(Date().timeIntervalSince(pressStartedAt) * 1000)
    }
}
