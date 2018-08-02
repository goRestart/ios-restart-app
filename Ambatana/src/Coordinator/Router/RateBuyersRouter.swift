import Foundation
import LGCoreKit

final class RateBuyersRouter: RateBuyersNavigator {

    private weak var navigationController: UINavigationController?

    private let chatAssembly: ChatAssembly
    private let rateUser: RateUserSource

    convenience init(navigationController: UINavigationController, source: RateUserSource) {
        self.init(navigationController: navigationController,
                  chatAssembly: LGChatBuilder.standard(nav: navigationController),
                  rateUser: source)
    }

    init(navigationController: UINavigationController, chatAssembly: ChatAssembly, rateUser: RateUserSource) {
        self.navigationController = navigationController
        self.chatAssembly = chatAssembly
        self.rateUser = rateUser
    }

    func rateBuyersCancel() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func rateBuyersFinish(withUser user: UserListing, listingId: String?) {
        guard let data = RateUserData(user: user, listingId: listingId, ratingType: .buyer) else {
            rateBuyersFinishNotOnLetgo()
            return
        }

        let vc = chatAssembly.buildRateUser(source: rateUser, data: data, showSkipButton: true)
        navigationController?.pushViewController(vc, animated: true)
    }

    func rateBuyersFinishNotOnLetgo() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

final class RateUserRouter: RateUserNavigator {
    private weak var navigationController: UINavigationController?
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func rateUserCancel() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func rateUserSkip() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func rateUserFinish(withRating rating: Int) {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
//            self?.delegate?.userRatingCoordinatorDidFinish(withRating: rating, ratedUserId: self?.ratedUserId)
    }
}
