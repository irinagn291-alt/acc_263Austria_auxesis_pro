import UIKit

/// Role: the only spacing accessor. One 8pt unit. Views never write a magic point.
public enum AuxSpace {
    public static let unit: CGFloat = 8

    public static func step(_ n: Int) -> CGFloat {
        unit * CGFloat(n)
    }

    public static var hairline: CGFloat { 0.5 }
    public static var hit: CGFloat { step(6) }
    public static var parallax: CGFloat { unit }
}
