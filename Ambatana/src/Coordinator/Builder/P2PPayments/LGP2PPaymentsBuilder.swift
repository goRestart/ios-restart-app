import Foundation

protocol P2PPaymentsAssembly {
    func buildOnboarding() -> UIViewController
}

enum LGP2PPaymentsBuilder {
    case modal(root: UIViewController)
}

extension LGP2PPaymentsBuilder: P2PPaymentsAssembly {
    func buildOnboarding() -> UIViewController {
        switch self {
        case .modal(root: let root):
            let vm = P2PPaymentsOnboardingViewModel()
            vm.navigator = P2PPaymentsWireframe(root: root)
            return P2PPaymentsOnboardingViewController(viewModel: vm)
        }
    }
}
