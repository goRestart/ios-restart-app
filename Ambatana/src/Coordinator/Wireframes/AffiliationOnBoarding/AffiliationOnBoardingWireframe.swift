protocol AffiliationOnBoardingNavigator {
    func close()
    func dismiss()
}

typealias AffiliationOnBoardingOnCompletion = ()->()

final class AffiliationOnBoardingWireframe: AffiliationOnBoardingNavigator {

    private let root: UIViewController
    private var onCompletion: AffiliationOnBoardingOnCompletion?

    init(root: UIViewController, onCompletion: AffiliationOnBoardingOnCompletion? = nil) {
        self.root = root
        self.onCompletion = onCompletion
    }

    func close() {
        root.dismiss(animated: true, completion: { [weak self] in
            self?.onCompletion?()
        })
    }

    func dismiss() {
        root.dismiss(animated: true, completion: nil)
    }
}
