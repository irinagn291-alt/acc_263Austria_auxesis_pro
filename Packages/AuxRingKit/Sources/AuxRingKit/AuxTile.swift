import UIKit

/// Role: bento surface. Mixed tile sizes sit on hairline plus fill.
public final class AuxTile: UIView {
    public init(radius: CGFloat = AuxRadius.surface) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        AuxElevation.apply(to: self, radius: radius)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused. This surface is built in code.")
    }
}
