import Foundation
import LGComponents

enum SearchFieldStyle {
    case letgoRed, grey
    
    var magnifierImage: UIImage { return self == .grey ?
        R.Asset.IconsButtons.listSearchGrey.image : R.Asset.IconsButtons.listSearch.image }
    
    var containerCornerRadius: CGFloat {
        switch self {
        case .letgoRed: return LGNavBarMetrics.Container.height / 2.0
        case .grey: return 10
        }
    }
    var imageTextSpacing: CGFloat {
        return self == .letgoRed ? 0 : 8
    }
    
    var shouldHideLetgoIcon: Bool { return self == .grey }
}
