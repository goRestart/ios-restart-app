protocol AffiliationOnBoardingNavigator {
    func close()
}

final class AffiliationOnBoardingWireframe: AffiliationOnBoardingNavigator {

    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func close() {
        root.dismiss(animated: true, completion: nil)
    }
}
