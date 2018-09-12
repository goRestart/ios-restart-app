import Foundation
import LGCoreKit

protocol P2PPaymentsOfferStatusAssembly {
    func buildOfferStatus(offerId: String) -> UIViewController
}

enum P2PPaymentsOfferStatusBuilder {
    case modal
    case standard(nc: UINavigationController)
}

extension P2PPaymentsOfferStatusBuilder: P2PPaymentsOfferStatusAssembly {
    func buildOfferStatus(offerId: String) -> UIViewController {
        let vm = P2PPaymentsOfferStatusViewModel(offerId: offerId)
        let vc = P2PPaymentsOfferStatusViewController(viewModel: vm)
        switch self {
        case .modal:
            let nc = UINavigationController(rootViewController: vc)
            vm.navigator = P2PPaymentsOfferStatusWireframe(offerId: offerId, navigationController: nc)
            return nc
        case .standard(nc: let nc):
            vm.navigator = P2PPaymentsOfferStatusWireframe(offerId: offerId, navigationController: nc)
            return vc
        }
    }

    func buildGetPayCode(offerId: String) -> UIViewController {
        let vm = P2PPaymentsGetPayCodeViewModel(offerId: offerId)
        let vc = P2PPaymentsGetPayCodeViewController(viewModel: vm)
        switch self {
        case .modal:
            let nc = UINavigationController(rootViewController: vc)
            vm.navigator = P2PPaymentsOfferStatusWireframe(offerId: offerId, navigationController: nc)
            return nc
        case .standard(nc: let nc):
            vm.navigator = P2PPaymentsOfferStatusWireframe(offerId: offerId, navigationController: nc)
            return vc
        }
    }

    func buildEnterPayCode(offerId: String) -> UIViewController {
        let vm = P2PPaymentsEnterPayCodeViewModel(offerId: offerId)
        let vc = P2PPaymentsEnterPayCodeViewController(viewModel: vm)
        switch self {
        case .modal:
            let nc = UINavigationController(rootViewController: vc)
            vm.navigator = P2PPaymentsOfferStatusWireframe(offerId: offerId, navigationController: nc)
            return nc
        case .standard(nc: let nc):
            vm.navigator = P2PPaymentsOfferStatusWireframe(offerId: offerId, navigationController: nc)
            return vc
        }
    }
}
