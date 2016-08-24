//
//  ChatsTabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

final class ChatsTabCoordinator: TabCoordinator {

    convenience init() {
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let myUserRepository = Core.myUserRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let chatGroupedVM = ChatGroupedViewModel()
        let rootViewController = ChatGroupedViewController(viewModel: chatGroupedVM)
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  myUserRepository: myUserRepository, keyValueStorage: keyValueStorage, tracker: tracker,
                  rootViewController: rootViewController)

        chatGroupedVM.tabNavigator = self
    }

    override func shouldHideSellButtonAtViewController(viewController: UIViewController) -> Bool {
        return true
    }

    func openChat(conversationData conversationData: ConversationData) {
        navigationController.showLoadingMessageAlert()

        let completion: (ChatResult) -> () = { [weak self] result in
            self?.openChatWithResult(result)
        }

        switch conversationData {
        case let .Conversation(conversationId):
            oldChatRepository.retrieveMessagesWithConversationId(conversationId, page: 0,
                                                                 numResults: Constants.numMessagesPerPage,
                                                                 completion: completion)
        case let .ProductBuyer(productId, buyerId):
            oldChatRepository.retrieveMessagesWithProductId(productId, buyerId: buyerId, page: 0,
                                                            numResults: Constants.numMessagesPerPage,
                                                            completion: completion)
        }
    }
}

extension ChatsTabCoordinator: ChatsTabNavigator {

}

private extension TabCoordinator {
    func openChatWithResult(result: ChatResult) {
        var dismissLoadingCompletion: (() -> Void)? = nil
        if let chat = result.value {
            guard let viewModel = OldChatViewModel(chat: chat, tabNavigator: self) else { return }
            let chatVC = OldChatViewController(viewModel: viewModel)
            dismissLoadingCompletion = { [weak self] in
                self?.navigationController.pushViewController(chatVC, animated: true)
            }

        } else if let error = result.error {
            let message: String
            switch error {
            case .Network:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                message = LGLocalizedString.commonChatNotAvailable
            }
            dismissLoadingCompletion = { [weak self] in
                self?.navigationController.showAutoFadingOutMessageAlert(message)
            }
        }
        navigationController.dismissLoadingMessageAlert(dismissLoadingCompletion)
    }
}
