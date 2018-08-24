import Foundation
import LGCoreKit

protocol ChatAssembly {
    func buildChatInactiveConversationsList() -> ChatInactiveConversationsListViewController
    func buildChatFrom(listing: Listing,
                       source: EventParameterTypePage,
                       openChatAutomaticMessage: ChatWrapperMessageType?,
                       interlocutor: User?) -> ChatViewController?
    func buildChatFrom(_ conversation: ChatConversation,
                       source: EventParameterTypePage,
                       predefinedMessage: String?) -> ChatViewController
}

enum LGChatBuilder {
    case standard(nav: UINavigationController)
}

extension LGChatBuilder: ChatAssembly {
    func buildChatInactiveConversationsList() -> ChatInactiveConversationsListViewController {
        switch self {
        case .standard(let nav):
            let vm = ChatInactiveConversationsListViewModel(navigator: ChatWireframe(nc: nav))
            return ChatInactiveConversationsListViewController(viewModel: vm)
        }
    }

    func buildChatFrom(listing: Listing,
                      source: EventParameterTypePage,
                      openChatAutomaticMessage: ChatWrapperMessageType?,
                      interlocutor: User?) -> ChatViewController? {
        switch self {
        case .standard(let nav):
            guard let vm = ChatViewModel(listing: listing,
                                             navigator: ChatDetailWireframe(nc: nav),
                                             source: source,
                                             openChatAutomaticMessage: openChatAutomaticMessage,
                                             interlocutor: interlocutor) else { return nil }
            let vc = ChatViewController(viewModel: vm, hidesBottomBar: source == .listingListFeatured)
            return vc
        }

    }

    func buildChatFrom(_ conversation: ChatConversation,
                          source: EventParameterTypePage,
                          predefinedMessage: String?)  -> ChatViewController {
        switch self {
        case .standard(let nav):
            let vm = ChatViewModel(conversation: conversation,
                                   navigator: ChatDetailWireframe(nc: nav),
                                   source: source,
                                   predefinedMessage: predefinedMessage)
            let vc = ChatViewController(viewModel: vm)
            return vc
        }
    }
}
