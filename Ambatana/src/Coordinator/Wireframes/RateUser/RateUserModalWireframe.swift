final class RateUserModalWireframe: RateUserNavigator {
    private let root: UIViewController
    private let deepLinkMailBox: DeepLinkMailBox
    private let onRateUserFinishAction: OnRateUserFinishActionable?

    convenience init(root: UIViewController, onRateUserFinishAction: OnRateUserFinishActionable?) {
        self.init(root: root, deepLinkMailBox: LGDeepLinkMailBox.sharedInstance, onRateUserFinishAction: onRateUserFinishAction)
    }

    private init(root: UIViewController, deepLinkMailBox: DeepLinkMailBox,
                 onRateUserFinishAction: OnRateUserFinishActionable?) {
        self.root = root
        self.deepLinkMailBox = deepLinkMailBox
        self.onRateUserFinishAction = onRateUserFinishAction
    }

    func rateUserCancel() {
        root.dismiss(animated: true) { [weak self] in
            self?.onRateUserFinishAction?.onFinish()
        }
    }

    func rateUserSkip() {
        root.dismiss(animated: true) { [weak self] in
            self?.onRateUserFinishAction?.onFinish()
        }
    }

    func rateUserFinish(withRating rating: UserRatingValue) {
        root.dismiss(animated: true, completion: { [weak self] in
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
