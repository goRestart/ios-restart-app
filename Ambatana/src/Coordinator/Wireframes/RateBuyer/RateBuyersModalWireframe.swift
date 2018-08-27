import LGCoreKit

final class RateBuyersModalWireframe: RateBuyersNavigator {
    private let root: UIViewController
    private let nc: UINavigationController

    private let rateUserAssembly: RateUserAssembly
    private let rateUser: RateUserSource

    convenience init(root: UIViewController,
                     nc: UINavigationController,
                     source: RateUserSource) {
        self.init(root: root,
                  nc: nc,
                  rateUserAssembly: RateUserBuilder.standard(nc),
                  rateUser: source)
    }

    init(root: UIViewController,
         nc: UINavigationController,
         rateUserAssembly: RateUserAssembly,
         rateUser: RateUserSource) {
        self.root = root
        self.nc = nc
        self.rateUserAssembly = rateUserAssembly
        self.rateUser = rateUser
    }

    func rateBuyersCancel() {
        root.dismiss(animated: true, completion: nil)
    }

    func rateBuyersFinish(withUser user: UserListing, listingId: String?) {
        guard let data = RateUserData(user: user,
                                      listingId: listingId,
                                      ratingType: .buyer) else {
            rateBuyersFinishNotOnLetgo()
            return
        }

        let vc = rateUserAssembly.buildRateUser(source: rateUser, data: data, showSkipButton: true)
        nc.pushViewController(vc, animated: true)
    }

    func rateBuyersFinishNotOnLetgo() {
        root.dismiss(animated: true, completion: nil)
    }
}
