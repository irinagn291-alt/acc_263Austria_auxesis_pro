import AuxCanvasCore
import AuxRingKit
import UIKit

/// Role: the one custom-drawn hero. Center-out rings as CAShapeLayers. No RealityKit.
@MainActor
final class RingStrataLayerRenderer {
    let host = UIView()

    private let strata = CALayer()
    private var strokes: [CAShapeLayer] = []
    private let jewel = CAShapeLayer()
    private let sealView = UIImageView()
    private var lastCount = -1

    init() {
        host.translatesAutoresizingMaskIntoConstraints = false
        host.isUserInteractionEnabled = false
        host.isAccessibilityElement = false
        host.layer.addSublayer(strata)
        jewel.fillColor = AuxColor.ink.cgColor
        jewel.opacity = 0.9
        strata.addSublayer(jewel)
        sealView.translatesAutoresizingMaskIntoConstraints = false
        sealView.contentMode = .scaleAspectFit
        sealView.image = AuxAsset.image(AuxAsset.fullMarkSeal)
        sealView.isHidden = true
        sealView.isAccessibilityElement = false
        host.addSubview(sealView)
        NSLayoutConstraint.activate([
            sealView.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -AuxSpace.step(1)),
            sealView.topAnchor.constraint(equalTo: host.topAnchor, constant: AuxSpace.step(1)),
            sealView.widthAnchor.constraint(equalToConstant: AuxSpace.step(7)),
            sealView.heightAnchor.constraint(equalToConstant: AuxSpace.step(7)),
        ])
    }

    func attachParallax() {
        host.motionEffects.removeAll()
        guard AuxMotion.shouldTravel else { return }
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -AuxSpace.parallax
        horizontal.maximumRelativeValue = AuxSpace.parallax
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -AuxSpace.unit
        vertical.maximumRelativeValue = AuxSpace.unit
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        host.addMotionEffect(group)
    }

    func render(rings: [Ring], sealed: Bool, guidedScale: CGFloat) {
        host.layoutIfNeeded()
        let bounds = host.bounds
        guard bounds.width > 1, bounds.height > 1 else { return }
        strata.frame = bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let maxRadius = min(bounds.width, bounds.height) * 0.48
        let slots = max(1, FullMarkSeal.ringCapacity)
        let step = maxRadius / CGFloat(slots)

        if AuxMotion.shouldTravel {
            var perspective = CATransform3DIdentity
            perspective.m34 = -1 / 900
            strata.sublayerTransform = perspective
        } else {
            strata.sublayerTransform = CATransform3DIdentity
        }

        while strokes.count < slots {
            let stroke = CAShapeLayer()
            stroke.fillColor = UIColor.clear.cgColor
            stroke.lineCap = .round
            strata.insertSublayer(stroke, below: jewel)
            strokes.append(stroke)
        }
        while strokes.count > slots {
            strokes.removeLast().removeFromSuperlayer()
        }

        for index in 0 ..< slots {
            let radius = step * CGFloat(index + 1)
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            let layer = strokes[index]
            layer.path = path.cgPath
            if index < rings.count {
                let ring = rings[index]
                layer.strokeColor = (ring.isSeed ? AuxColor.muted : AuxColor.accent)
                    .withAlphaComponent(0.72 + 0.04 * CGFloat(index))
                    .cgColor
                layer.lineWidth = ring.isSeed ? 3 : 4 + CGFloat(index) * 0.6
            } else {
                layer.strokeColor = AuxColor.muted.withAlphaComponent(0.28).cgColor
                layer.lineWidth = 2
            }
            if AuxMotion.shouldTravel {
                layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, CGFloat(index) * 3)
            } else {
                layer.transform = CATransform3DIdentity
            }
            if index == rings.count - 1, index >= 0, guidedScale != 1 {
                let grown = UIBezierPath(
                    arcCenter: center,
                    radius: radius * guidedScale,
                    startAngle: 0,
                    endAngle: .pi * 2,
                    clockwise: true
                )
                layer.path = grown.cgPath
            }
        }

        if let last = rings.last {
            let radius = step * CGFloat(rings.count)
            let jewelRadius = AuxSpace.unit
            let angle = CGFloat(-Double.pi / 3)
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            jewel.path = UIBezierPath(
                ovalIn: CGRect(
                    x: point.x - jewelRadius / 2,
                    y: point.y - jewelRadius / 2,
                    width: jewelRadius,
                    height: jewelRadius
                )
            ).cgPath
            jewel.isHidden = false
            jewel.fillColor = (last.isSeed ? AuxColor.muted : AuxColor.ink).cgColor
        } else {
            jewel.isHidden = true
        }

        sealView.isHidden = !sealed
        if lastCount != rings.count, lastCount >= 0 {
            if AuxMotion.shouldTravel {
                let fade = CABasicAnimation(keyPath: "opacity")
                fade.fromValue = 0.35
                fade.toValue = 1
                fade.duration = AuxMotion.fade
                fade.timingFunction = CAMediaTimingFunction(name: .easeOut)
                strata.add(fade, forKey: "ringFade")
            }
        }
        lastCount = rings.count
    }
}
