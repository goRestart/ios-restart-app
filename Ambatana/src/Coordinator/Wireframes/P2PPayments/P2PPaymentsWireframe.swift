import Foundation

protocol P2PPaymentsNavigator {
    func closeOnboarding()
    func openMakeAnOffer()
}

final class P2PPaymentsWireframe: P2PPaymentsNavigator {
    private let navigationController: UINavigationController
    private let assembly: P2PPaymentsAssembly

    convenience init(navigationController: UINavigationController) {
        self.init(navigationController: navigationController,
                  assembly: LGP2PPaymentsBuilder.standard(nc: navigationController))
    }

    init(navigationController: UINavigationController,
         assembly: P2PPaymentsAssembly) {
        self.navigationController = navigationController
        self.assembly = assembly
    }

    func closeOnboarding() {
        navigationController.dismiss(animated: true)
    }

    func openMakeAnOffer() {
        let vc = assembly.buildMakeAnOffer()
        navigationController.pushViewController(vc, animated: true)
    }
}
