import Foundation
import LGCoreKit

protocol RateAssembly {
    func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool) -> RateUserViewController
    func buildRateBuyers(into navCtl: UINavigationController,
                         source: RateUserSource,
                         buyers: [UserListing],
                         listingId: String,
                         sourceRateBuyers: SourceRateBuyers?,
                         trackingInfo: MarkAsSoldTrackingInfo) -> RateBuyersViewController
    
}

enum LGRateBuilder {
    case modal(root: UIViewController)
}


extension LGRateBuilder: RateAssembly {
    func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool) -> RateUserViewController {
        switch self {
        case .modal(let root):
            let vm = RateUserViewModel(source: source, data: data)
            let vc = RateUserViewController(viewModel: vm, showSkipButton: showSkipButton)
            vm.navigator = RateUserRouter(root: root)
            return vc
        }
    }
    func buildRateBuyers(into navCtl: UINavigationController,
                         source: RateUserSource,
                         buyers: [UserListing],
                         listingId: String,
                         sourceRateBuyers: SourceRateBuyers?,
                         trackingInfo: MarkAsSoldTrackingInfo) -> RateBuyersViewController {
        switch self {
        case .modal(let root):
            let vm = RateBuyersViewModel(buyers: buyers,
                                         listingId: listingId,
                                         source: sourceRateBuyers,
                                         trackingInfo: trackingInfo)
            let vc = RateBuyersViewController(with: vm)
            navCtl.viewControllers = [vc]
            vm.navigator = RateBuyersRouter(root: root, navigationController: navCtl, source: source)
            return vc
        }
    }
}
