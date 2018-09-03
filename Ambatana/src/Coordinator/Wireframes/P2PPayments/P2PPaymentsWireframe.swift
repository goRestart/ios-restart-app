import Foundation

protocol P2PPaymentsNavigator {
    func closeOnboarding()
}

final class P2PPaymentsWireframe: P2PPaymentsNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func closeOnboarding() {
        root.dismiss(animated: true)
    }
}
