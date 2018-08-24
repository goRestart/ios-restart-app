import LGCoreKit

protocol ChatInactiveDetailAssembly {
    func buildChatInactiveConversationDetails(conversation: ChatInactiveConversation) -> ChatInactiveConversationDetailsViewController
}

enum ChatInactiveDetailBuilder {
    case standard(UINavigationController)
}

extension ChatInactiveDetailBuilder: ChatInactiveDetailAssembly {
    func buildChatInactiveConversationDetails(conversation: ChatInactiveConversation) -> ChatInactiveConversationDetailsViewController {
        let vm = ChatInactiveConversationDetailsViewModel(conversation: conversation)
        let vc = ChatInactiveConversationDetailsViewController(viewModel: vm)
        vm.delegate = vc
        switch self {
        case .standard(let nav):
            vm.navigator = ChatInactiveDetailWireframe(nc: nav)
            return vc
        }
    }
}
