import Foundation
import LGCoreKit

final class ProfessionalDealerAskPhoneModalWireframe: ProfessionalDealerAskPhoneNavigator {
    private let root: UIViewController
    private let chatRouter: ChatWireframe

    convenience init(root: UIViewController, nc: UINavigationController) {
        self.init(root: root, chatRouter: ChatWireframe(nc: nc))
    }

    init(root: UIViewController, chatRouter: ChatWireframe) {
        self.root = root
        self.chatRouter = chatRouter
    }

    func closeAskPhoneFor(listing: Listing,
                          openChat: Bool,
                          withPhoneNum: String?,
                          source: EventParameterTypePage,
                          interlocutor: User?) {
        var completion: (()->())? = nil
        if openChat {
            completion = {
                var openChatAutomaticMessage: ChatWrapperMessageType? = nil
                if let phone = withPhoneNum {
                    openChatAutomaticMessage = .phone(phone)
                }
                self.chatRouter.openListingChat(listing,
                                                source: source,
                                                interlocutor: interlocutor,
                                                openChatAutomaticMessage: openChatAutomaticMessage)
            }
        }
        root.dismiss(animated: true, completion: completion)
    }
}
