import UIKit

/// Role: the only colour accessor. Named assets from section 7.1. Views never write a hex.
@MainActor
public enum AuxColor {
    /// Screen background `#284840`
    public static var background: UIColor { named("background") }
    /// Cards, rows, sheets `#38574F`
    public static var surface: UIColor { named("surface") }
    /// Primary text and icons `#F4F6F5`
    public static var ink: UIColor { named("ink") }
    /// Primary action, key figure, progress fill `#73DEC3`
    public static var accent: UIColor { named("accent") }
    /// Secondary text, dividers, disabled `#B6C3C0`
    public static var muted: UIColor { named("muted") }

    private static func named(_ name: String) -> UIColor {
        UIColor(named: name, in: .main, compatibleWith: nil) ?? .label
    }
}
