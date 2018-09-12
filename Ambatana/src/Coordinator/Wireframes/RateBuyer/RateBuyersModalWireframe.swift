import LGCoreKit

final class RateBuyersModalWireframe: RateBuyersNavigator {
    private let root: UIViewController
    private let nc: UINavigationController

    private let rateUserAssembly: RateUserAssembly
    private let postAnotherListingAssembly: PostAnotherListingAssembly
    private let rateUser: RateUserSource
    private let onRateUserFinishAction: OnRateUserFinishActionable?

    convenience init(root: UIViewController,
                     nc: UINavigationController,
                     source: RateUserSource,
                     onRateUserFinishAction: OnRateUserFinishActionable?) {
        self.init(root: root,
                  nc: nc,
                  rateUserAssembly: RateUserBuilder.standard(nc),
                  postAnotherListingAssembly: PostAnotherListingBuilder.modal(root),
                  rateUser: source,
                  onRateUserFinishAction: onRateUserFinishAction)
    }

    init(root: UIViewController,
         nc: UINavigationController,
         rateUserAssembly: RateUserAssembly,
         postAnotherListingAssembly: PostAnotherListingAssembly,
         rateUser: RateUserSource,
         onRateUserFinishAction: OnRateUserFinishActionable?) {
        self.root = root
        self.nc = nc
        self.rateUserAssembly = rateUserAssembly
        self.postAnotherListingAssembly = postAnotherListingAssembly
        self.rateUser = rateUser
        self.onRateUserFinishAction = onRateUserFinishAction
    }

    func rateBuyersCancel() {
        root.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self, strongSelf.rateUser == .markAsSold else { return }
            let vc = strongSelf.postAnotherListingAssembly.buildPostAnotherListing()
            strongSelf.root.present(vc, animated: true, completion: nil)
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
        nc.pushViewController(vc, animated: true)
    }

    func rateBuyersFinishNotOnLetgo() {
        root.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self, strongSelf.rateUser == .markAsSold else { return }
            let vc = strongSelf.postAnotherListingAssembly.buildPostAnotherListing()
            strongSelf.root.present(vc, animated: true, completion: nil)
        }
    }
}
