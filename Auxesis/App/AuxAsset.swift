import UIKit

/// Role: section 13 image set names. Empty imagesets are filled by a later assets step.
enum AuxAsset {
    static let onboarding1 = "aux_Onboarding1"
    static let onboarding2 = "aux_Onboarding2"
    static let onboarding3 = "aux_Onboarding3"
    static let emptyHome = "aux_EmptyHome"
    static let emptyList = "aux_EmptyList"
    static let cardBackdrop = "aux_CardBackdrop"
    static let controlFace = "aux_ControlFace"
    static let twistHero = "aux_TwistHero"
    static let successMark = "aux_SuccessMark"
    static let headerDecor = "aux_HeaderDecor"
    static let practicesEmpty = "aux_PracticesEmpty"
    static let statsEmpty = "aux_StatsEmpty"
    static let fullMarkSeal = "aux_FullMarkSeal"
    static let seedRing = "aux_SeedRing"

    static func image(_ name: String) -> UIImage? {
        UIImage(named: name)
    }
}
