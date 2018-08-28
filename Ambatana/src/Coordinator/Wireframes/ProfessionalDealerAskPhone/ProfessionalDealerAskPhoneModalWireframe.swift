import Foundation
import LGCoreKit

final class ProfessionalDealerAskPhoneModalWireframe: ProfessionalDealerAskPhoneNavigator {
    private let root: UIViewController
    private let chatNavigator: ChatNavigator

    init(root: UIViewController, chatNavigator: ChatNavigator) {
        self.root = root
        self.chatNavigator = chatNavigator
    }

    func closeAskPhoneFor(listing: Listing,
                          openChat: Bool,
                          withPhoneNum: String?,
                          source: EventParameterTypePage,
                          interlocutor: User?) {
        var completion: (()->())? = nil
        if openChat {
            completion = { [weak self] in
                var openChatAutomaticMessage: ChatWrapperMessageType? = nil
                if let phone = withPhoneNum {
                    openChatAutomaticMessage = .phone(phone)
                }
                self?.chatNavigator.openListingChat(listing,
                                                    source: source,
                                                    interlocutor: interlocutor,
                                                    openChatAutomaticMessage: openChatAutomaticMessage)
            }
        }
        root.dismiss(animated: true, completion: completion)
    }
}
