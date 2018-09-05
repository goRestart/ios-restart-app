final class RateUserStandardWireframe: RateUserNavigator {
    private let nc: UINavigationController
    private let deepLinkMailBox: DeepLinkMailBox

    convenience init(nc: UINavigationController) {
        self.init(nc: nc, deepLinkMailBox: LGDeepLinkMailBox.sharedInstance)
    }

    private init(nc: UINavigationController, deepLinkMailBox: DeepLinkMailBox) {
        self.nc = nc
        self.deepLinkMailBox = deepLinkMailBox
    }
    func rateUserCancel() {
        nc.dismiss(animated: true, completion: nil)
    }

    func rateUserSkip() {
        nc.dismiss(animated: true, completion: nil)
    }

    func rateUserFinish(withRating rating: UserRatingValue) {
        nc.dismiss(animated: true, completion: { [weak self] in
            if rating.shouldShowAppRating {
                self?.openAppRating(.chat)
            }
        })
    }

    private func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deepLinkMailBox.push(convertible: url)
    }
}
