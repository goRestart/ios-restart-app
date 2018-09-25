import Foundation
import LGCoreKit

protocol P2PPaymentsMakeAnOfferNavigator {
    func closeOnboarding()
    func openMakeAnOffer()
    func openContactUs(url: URL)
    func openFaqs(url: URL)
}

final class P2PPaymentsMakeAnOfferWireframe: P2PPaymentsMakeAnOfferNavigator {
    private let chatConversation: ChatConversation
    private weak var navigationController: UINavigationController?

    init(chatConversation: ChatConversation,
         navigationController: UINavigationController) {
        self.chatConversation = chatConversation
        self.navigationController = navigationController
    }

    func closeOnboarding() {
        navigationController?.dismiss(animated: true)
    }

    func openMakeAnOffer() {
        guard let nc = navigationController else { return }
        let vc = P2PPaymentsMakeAnOfferBuilder.standard(nc: nc).buildMakeAnOffer(chatConversation: chatConversation)
        navigationController?.setViewControllers([vc], animated: true)
    }

    func openContactUs(url: URL) {
        navigationController?.openInAppWebViewWith(url: url)
    }

    func openFaqs(url: URL) {
        navigationController?.openInAppWebViewWith(url: url)
    }
}
