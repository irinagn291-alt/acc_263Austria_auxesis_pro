import UIKit

/// Role: the only colour accessor. Named assets from section 7.1. Views never write a hex.
@MainActor
public enum AuxColor {
    /// Screen background `#144714`
    public static var background: UIColor { named("background") }
    /// Cards, rows, sheets `#306B31`
    public static var surface: UIColor { named("surface") }
    /// Primary text and icons `#FFF6FC`
    public static var ink: UIColor { named("ink") }
    /// Primary action, key figure, progress fill `#2EFF30`
    public static var accent: UIColor { named("accent") }
    /// Secondary text, dividers, disabled `#9EDB9E`
    public static var muted: UIColor { named("muted") }

    private static func named(_ name: String) -> UIColor {
        UIColor(named: name, in: .main, compatibleWith: nil) ?? .label
    }
}
