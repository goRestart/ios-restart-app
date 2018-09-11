import Foundation
import LGCoreKit

protocol P2PPaymentsOfferStatusNavigator {
    func close()
}

final class P2PPaymentsOfferStatusWireframe: P2PPaymentsOfferStatusNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func close() {
        navigationController?.dismiss(animated: true)
    }
}
