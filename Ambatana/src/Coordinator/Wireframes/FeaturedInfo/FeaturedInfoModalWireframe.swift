import Foundation

final class FeaturedInfoModalWireframe: FeaturedInfoNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func closeFeaturedInfo() {
        root.dismiss(animated: true, completion: nil)
    }
}
