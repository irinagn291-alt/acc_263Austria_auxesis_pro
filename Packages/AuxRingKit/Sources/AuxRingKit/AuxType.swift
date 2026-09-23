import UIKit

/// Role: the only type accessor. SF Pro Rounded, five steps, tabular figures.
@MainActor
public enum AuxType {
    public static func canvasFigure(compatibleWith traits: UITraitCollection? = nil) -> UIFont {
        let category = traits?.preferredContentSizeCategory ?? UITraitCollection.current.preferredContentSizeCategory
        let size: CGFloat = category >= .accessibilityExtraExtraExtraLarge ? 22 : 40
        return rounded(size: size, weight: .semibold, tabular: true)
    }

    public static func sectionTitle() -> UIFont {
        rounded(size: 22, weight: .semibold, tabular: false)
    }

    public static func body() -> UIFont {
        rounded(size: 17, weight: .regular, tabular: false)
    }

    public static func caption() -> UIFont {
        rounded(size: 13, weight: .medium, tabular: true)
    }

    /// Two-digit calendar marks. Tabular 15pt, not Dynamic Type scaled.
    public static func dayMark() -> UIFont {
        let base = UIFont.systemFont(ofSize: 15, weight: .semibold)
        var descriptor = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
        descriptor = descriptor.addingAttributes([
            .featureSettings: [
                [
                    UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                    UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector,
                ],
            ],
        ])
        return UIFont(descriptor: descriptor, size: 15)
    }

    public static func hairline() -> UIFont {
        rounded(size: 11, weight: .medium, tabular: true)
    }

    public static func hairlineAttributed(_ text: String, color: UIColor) -> NSAttributedString {
        NSAttributedString(
            string: text.uppercased(),
            attributes: [
                .font: hairline(),
                .foregroundColor: color,
                .kern: 0.6,
            ]
        )
    }

    private static func rounded(size: CGFloat, weight: UIFont.Weight, tabular: Bool) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        var descriptor = base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor
        if tabular {
            descriptor = descriptor.addingAttributes([
                .featureSettings: [
                    [
                        UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                        UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector,
                    ],
                ],
            ])
        }
        let font = UIFont(descriptor: descriptor, size: size)
        return UIFontMetrics(forTextStyle: style(for: size)).scaledFont(for: font)
    }

    private static func style(for size: CGFloat) -> UIFont.TextStyle {
        if size >= 40 { return .largeTitle }
        if size >= 22 { return .title2 }
        if size >= 17 { return .body }
        if size >= 13 { return .footnote }
        return .caption2
    }
}
