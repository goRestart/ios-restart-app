final class RateUserModalWireframe: RateUserNavigator {
    private let root: UIViewController
    private let deepLinkMailBox: DeepLinkMailBox

    convenience init(root: UIViewController) {
        self.init(root: root, deepLinkMailBox: LGDeepLinkMailBox.sharedInstance)
    }

    private init(root: UIViewController, deepLinkMailBox: DeepLinkMailBox) {
        self.root = root
        self.deepLinkMailBox = deepLinkMailBox
    }
    func rateUserCancel() {
        root.dismiss(animated: true, completion: nil)
    }

    func rateUserSkip() {
        root.dismiss(animated: true, completion: nil)
    }

    func rateUserFinish(withRating rating: UserRatingValue) {
        root.dismiss(animated: true, completion: { [weak self] in
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
