import Foundation
import LGCoreKit

protocol RateBuyersNavigator: class {
    func rateBuyersCancel()
    func rateBuyersFinish(withUser: UserListing, listingId: String?)
    func rateBuyersFinishNotOnLetgo()
}

protocol RateUserNavigator: class {
    func rateUserCancel()
    func rateUserSkip()
    func rateUserFinish(withRating rating: Int)
}

final class RateBuyersRouter: RateBuyersNavigator {
    private weak var root: UIViewController?
    private weak var navigationController: UINavigationController?

    private let assembly: RateAssembly
    private let rateUser: RateUserSource

    convenience init(root: UIViewController,
                     navigationController: UINavigationController,
                     source: RateUserSource) {
        self.init(root: root,
                  navigationController: navigationController,
                  assembly: LGRateBuilder.modal(root: root),
                  rateUser: source)
    }

    init(root: UIViewController,
         navigationController: UINavigationController,
         assembly: RateAssembly,
         rateUser: RateUserSource) {
        self.root = root
        self.navigationController = navigationController
        self.assembly = assembly
        self.rateUser = rateUser
    }

    func rateBuyersCancel() {
        root?.dismiss(animated: true, completion: nil)
    }

    func rateBuyersFinish(withUser user: UserListing, listingId: String?) {
        guard let data = RateUserData(user: user, listingId: listingId, ratingType: .buyer) else {
            rateBuyersFinishNotOnLetgo()
            return
        }

        let vc = assembly.buildRateUser(source: rateUser, data: data, showSkipButton: true)
        navigationController?.pushViewController(vc, animated: true)
    }

    func rateBuyersFinishNotOnLetgo() {
        root?.dismiss(animated: true, completion: nil)
    }
}

final class RateUserRouter: RateUserNavigator {
    private weak var root: UIViewController?
    private let deepLinkMailBox: DeepLinkMailBox

    convenience init(root: UIViewController) {
        self.init(root: root, deepLinkMailBox: LGDeepLinkMailBox.sharedInstance)
    }

    private init(root: UIViewController, deepLinkMailBox: DeepLinkMailBox) {
        self.root = root
        self.deepLinkMailBox = deepLinkMailBox
    }
    func rateUserCancel() {
        root?.dismiss(animated: true, completion: nil)
    }

    func rateUserSkip() {
        root?.dismiss(animated: true, completion: nil)
    }

    func rateUserFinish(withRating rating: Int) {
        root?.dismiss(animated: true, completion: { [weak self] in
            if rating == 5 {
                self?.openAppRating(.chat)
            }
        })
    }

    private func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deepLinkMailBox.push(convertible: url)
    }

}
