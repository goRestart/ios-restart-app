import Foundation
import LGCoreKit

protocol P2PPaymentsMakeAnOfferNavigator {
    func closeOnboarding()
    func openMakeAnOffer()
}

final class P2PPaymentsMakeAnOfferWireframe: P2PPaymentsMakeAnOfferNavigator {
    private let chatConversation: ChatConversation
    private let navigationController: UINavigationController
    private let assembly: P2PPaymentsMakeAnOfferAssembly

    convenience init(chatConversation: ChatConversation,
                     navigationController: UINavigationController) {
        self.init(chatConversation: chatConversation,
                  navigationController: navigationController,
                  assembly: P2PPaymentsMakeAnOfferBuilder.standard(nc: navigationController))
    }

    init(chatConversation: ChatConversation,
         navigationController: UINavigationController,
         assembly: P2PPaymentsMakeAnOfferAssembly) {
        self.chatConversation = chatConversation
        self.navigationController = navigationController
        self.assembly = assembly
    }

    func closeOnboarding() {
        navigationController.dismiss(animated: true)
    }

    func openMakeAnOffer() {
        let vc = assembly.buildMakeAnOffer(chatConversation: chatConversation)
        navigationController.addFadeTransition()
        navigationController.setViewControllers([vc], animated: false)
    }
}
