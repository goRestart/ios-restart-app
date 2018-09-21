import Foundation
import LGCoreKit

protocol P2PPaymentsMakeAnOfferAssembly {
    func buildOnboarding(chatConversation: ChatConversation) -> UIViewController
    func buildMakeAnOffer(chatConversation: ChatConversation) -> UIViewController
}

enum P2PPaymentsMakeAnOfferBuilder {
    case modal
    case standard(nc: UINavigationController)
}

extension P2PPaymentsMakeAnOfferBuilder: P2PPaymentsMakeAnOfferAssembly {
    func buildOnboarding(chatConversation: ChatConversation) -> UIViewController {
        let vm = P2PPaymentsOnboardingViewModel()
        let vc = P2PPaymentsOnboardingViewController(viewModel: vm)
        switch self {
        case .modal:
            let nc = UINavigationController(rootViewController: vc)
            nc.modalPresentationStyle = .formSheet
            vm.navigator = P2PPaymentsMakeAnOfferWireframe(chatConversation: chatConversation, navigationController: nc)
            return nc
        case .standard(nc: let nc):
            vm.navigator = P2PPaymentsMakeAnOfferWireframe(chatConversation: chatConversation, navigationController: nc)
            return vc
        }
    }

    func buildMakeAnOffer(chatConversation: ChatConversation) -> UIViewController {
        let vm = P2PPaymentsCreateOfferViewModel(chatConversation: chatConversation)
        let vc = P2PPaymentsCreateOfferViewController(viewModel: vm)
        vm.delegate = vc
        switch self {
        case .modal:
            let nc = UINavigationController(rootViewController: vc)
            nc.modalPresentationStyle = .formSheet
            vm.navigator = P2PPaymentsMakeAnOfferWireframe(chatConversation: chatConversation, navigationController: nc)
            return nc
        case .standard(nc: let nc):
            vm.navigator = P2PPaymentsMakeAnOfferWireframe(chatConversation: chatConversation, navigationController: nc)
            return vc
        }
    }
}
