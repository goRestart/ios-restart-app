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
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let viewModel = ChatGroupedViewModel()
        let rootViewController = ChatGroupedViewController(viewModel: viewModel)

        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  keyValueStorage: keyValueStorage, tracker: tracker, rootViewController: rootViewController)
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

private extension TabCoordinator {
    func openChatWithResult(result: ChatResult) {
        var dismissLoadingCompletion: (() -> Void)? = nil
        if let chat = result.value {
            guard let viewModel = OldChatViewModel(chat: chat) else { return }
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
