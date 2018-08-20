import Foundation

protocol P2PPaymentsNavigator {
    func closeOnboarding()
}

final class P2PPaymentsRouter: P2PPaymentsNavigator {
    private weak var root: UIViewController?

    init(root: UIViewController) {
        self.root = root
    }

    func closeOnboarding() {
        root?.dismiss(animated: true)
    }
}
