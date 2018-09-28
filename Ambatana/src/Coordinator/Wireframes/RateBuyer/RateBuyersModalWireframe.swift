import LGCoreKit

final class RateBuyersModalWireframe: RateBuyersNavigator {
    private let root: UIViewController
    private weak var nc: UINavigationController?

    private let rateUserAssembly: RateUserAssembly
    private let rateUser: RateUserSource
    private let onRateUserFinishAction: OnRateUserFinishActionable?

    convenience init(root: UIViewController,
                     nc: UINavigationController,
                     source: RateUserSource,
                     onRateUserFinishAction: OnRateUserFinishActionable?) {
        self.init(root: root,
                  nc: nc,
                  rateUserAssembly: RateUserBuilder.standard(nc),
                  rateUser: source,
                  onRateUserFinishAction: onRateUserFinishAction)
    }

    init(root: UIViewController,
         nc: UINavigationController,
         rateUserAssembly: RateUserAssembly,
         rateUser: RateUserSource,
         onRateUserFinishAction: OnRateUserFinishActionable?) {
        self.root = root
        self.nc = nc
        self.rateUserAssembly = rateUserAssembly
        self.rateUser = rateUser
        self.onRateUserFinishAction = onRateUserFinishAction
    }

    func rateBuyersCancel() {
        root.dismiss(animated: true) { [weak self] in
            self?.onRateUserFinishAction?.onFinish()
        }
    }

    func rateBuyersFinish(withUser user: UserListing, listingId: String?) {
        guard let data = RateUserData(user: user,
                                      listingId: listingId,
                                      ratingType: .buyer) else {
            rateBuyersFinishNotOnLetgo()
            return
        }

        let vc = rateUserAssembly.buildRateUser(source: rateUser, data: data, showSkipButton: true,
                                                onRateUserFinishAction: onRateUserFinishAction)
        nc?.pushViewController(vc, animated: true)
    }

    func rateBuyersFinishNotOnLetgo() {
        root.dismiss(animated: true) { [weak self] in
            self?.onRateUserFinishAction?.onFinish()
        }
    }
}
