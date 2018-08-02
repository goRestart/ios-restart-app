import Foundation

final class ExpressChatRouter: ExpressChatNavigator {
    private weak var root: UIViewController?

    init(root: UIViewController) {
        self.root = root
    }

    func closeExpressChat(_ showAgain: Bool, forProduct: String) {
        root?.dismiss(animated: true, completion: nil)
    }

    func sentMessage(_ forProduct: String, count: Int) {
        root?.dismiss(animated: true, completion: nil)
    }
}
