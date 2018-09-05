import Foundation

protocol P2PPaymentsAssembly {
    func buildOnboarding() -> UIViewController
    func buildMakeAnOffer() -> UIViewController
}

enum LGP2PPaymentsBuilder {
    case modal
    case standard(nc: UINavigationController)
}

extension LGP2PPaymentsBuilder: P2PPaymentsAssembly {
    func buildOnboarding() -> UIViewController {
        let vm = P2PPaymentsOnboardingViewModel()
        let vc = P2PPaymentsOnboardingViewController(viewModel: vm)
        switch self {
        case .modal:
            let nc = UINavigationController(rootViewController: vc)
            vm.navigator = P2PPaymentsWireframe(navigationController: nc)
            return nc
        case .standard(nc: let nc):
            vm.navigator = P2PPaymentsWireframe(navigationController: nc)
            return vc
        }
    }

    func buildMakeAnOffer() -> UIViewController {
        let vm = P2PPaymentsCreateOfferViewModel()
        let vc = P2PPaymentsCreateOfferViewController(viewModel: vm)
        switch self {
        case .modal:
            let nc = UINavigationController(rootViewController: vc)
            vm.navigator = P2PPaymentsWireframe(navigationController: nc)
            return nc
        case .standard(nc: let nc):
            vm.navigator = P2PPaymentsWireframe(navigationController: nc)
            return vc
        }
    }
}
