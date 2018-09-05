protocol ListingDeckOnBoardingNavigator: class {
    func close()
}

final class ListingDeckOnBoardingWireframe: ListingDeckOnBoardingNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func close() {
        root.dismiss(animated: true, completion: nil)
    }
}
