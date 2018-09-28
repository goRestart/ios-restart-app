final class RateUserStandardWireframe: RateUserNavigator {
    private weak var nc: UINavigationController?
    private let deepLinkMailBox: DeepLinkMailBox
    private let onRateUserFinishAction: OnRateUserFinishActionable?

    convenience init(nc: UINavigationController, onRateUserFinishAction: OnRateUserFinishActionable?) {
        self.init(nc: nc, deepLinkMailBox: LGDeepLinkMailBox.sharedInstance, onRateUserFinishAction: onRateUserFinishAction)
    }

    private init(nc: UINavigationController, deepLinkMailBox: DeepLinkMailBox, onRateUserFinishAction: OnRateUserFinishActionable?) {
        self.nc = nc
        self.deepLinkMailBox = deepLinkMailBox
        self.onRateUserFinishAction = onRateUserFinishAction
    }
    func rateUserCancel() {
        nc?.dismiss(animated: true, completion: { [weak self] in
            self?.onRateUserFinishAction?.onFinish()
        })
    }

    func rateUserSkip() {
        nc?.dismiss(animated: true, completion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.onRateUserFinishAction?.onFinish()
        })
    }

    func rateUserFinish(withRating rating: UserRatingValue) {
        nc?.dismiss(animated: true, completion: { [weak self] in
            if rating.shouldShowAppRating {
                self?.openAppRating(.chat)
            } else {
                self?.onRateUserFinishAction?.onFinish()
            }
        })
    }

    private func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deepLinkMailBox.push(convertible: url)
    }
}
