import Foundation
import LGCoreKit
import LGComponents

final class P2PPaymentsCreateOfferViewModel: BaseViewModel {
    var navigator: P2PPaymentsMakeAnOfferNavigator?
    private let chatConversation: ChatConversation
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let myUserRepository: MyUserRepository

    convenience init(chatConversation: ChatConversation) {
        self.init(chatConversation: chatConversation,
                  p2pPaymentsRepository: Core.p2pPaymentsRepository,
                  myUserRepository: Core.myUserRepository)
    }

    init(chatConversation: ChatConversation,
         p2pPaymentsRepository: P2PPaymentsRepository,
         myUserRepository: MyUserRepository) {
        self.chatConversation = chatConversation
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.myUserRepository = myUserRepository
        super.init()
    }

    func closeButtonPressed() {
        navigator?.closeOnboarding()
    }
}
