import Foundation
import LGCoreKit

protocol RateBuyerAssembly {
    func buildRateBuyers(source: RateUserSource,
                         buyers: [UserListing],
                         listingId: String,
                         sourceRateBuyers: SourceRateBuyers?,
                         trackingInfo: MarkAsSoldTrackingInfo,
                         onRateUserFinishAction: OnRateUserFinishActionable?) -> UIViewController
}

enum RateBuyerBuilder {
    case modal(UINavigationController)
}

extension RateBuyerBuilder: RateBuyerAssembly {
    func buildRateBuyers(source: RateUserSource,
                         buyers: [UserListing],
                         listingId: String,
                         sourceRateBuyers: SourceRateBuyers?,
                         trackingInfo: MarkAsSoldTrackingInfo,
                         onRateUserFinishAction: OnRateUserFinishActionable?) -> UIViewController {
        let vm = RateBuyersViewModel(buyers: buyers,
                                     listingId: listingId,
                                     source: sourceRateBuyers,
                                     trackingInfo: trackingInfo)
        let vc = RateBuyersViewController(with: vm)
        switch self {
        case .modal(let root):
            let navCtl = UINavigationController(rootViewController: vc)
            vm.navigator = RateBuyersModalWireframe(root: root, nc: navCtl, source: source, onRateUserFinishAction: onRateUserFinishAction)
            return navCtl
        }
    }
}

