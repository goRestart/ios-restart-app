import LGComponents
import LGCoreKit

enum AdType: Equatable {
    case native, banner
}

struct AdData: Diffable {
    let adPosition: Int
    let height: CGFloat
    let type: AdType
}

extension AdData {
    struct Lenses {
        static let height = Lens<AdData, CGFloat>(
            get: {$0.height},
            set: {(value, me) in AdData(adPosition: me.adPosition, height: value, type: me.type) }
        )
    }
}

extension AdData {
    var diffIdentifier: String {
        return "\(type)-\(adPosition)"
    }
}

struct AdDataFactory {
    static func make(adPosition: Int,
                     bannerHeight: CGFloat = LGUIKitConstants.advertisementCellPlaceholderHeight,
                     type: AdType = .native) -> AdData {
        return AdData(adPosition: adPosition,
                      height: bannerHeight,
                      type: type)
    }
}
