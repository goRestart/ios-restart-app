//
//  TabCoordinator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class TabCoordinator {
    var child: Coordinator?

    private let navigationController: UINavigationController

    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let chatRepository: ChatRepository
    private let oldChatRepository: OldChatRepository
    private let keyValueStorage: KeyValueStorage
    private let tracker: Tracker

    private let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init(navigationController: UINavigationController) {
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let oldChatRepository = Core.oldChatRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        self.init(productRepository: productRepository, userRepository: userRepository,
                  chatRepository: chatRepository, oldChatRepository: oldChatRepository,
                  keyValueStorage: keyValueStorage, tracker: tracker, navigationController: navigationController)
    }

    init(productRepository: ProductRepository, userRepository: UserRepository, chatRepository: ChatRepository,
         oldChatRepository: OldChatRepository, keyValueStorage: KeyValueStorage, tracker: Tracker,
         navigationController: UINavigationController) {
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.navigationController = navigationController
    }
}


// MARK: - TabNavigator

extension TabCoordinator: TabNavigator {
    func openUser(user user: User) {
        let viewModel = UserViewModel(user: user, source: .TabBar)
        let vc = UserViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func openUser(userId userId: String) {
        navigationController.showLoadingMessageAlert()
        userRepository.show(userId, includeAccounts: false) { [weak self] result in
            if let user = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openUser(user: user)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                    message = LGLocalizedString.commonUserNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message)
                }
            }
        }
    }

    func openProduct(product product: Product) {
        guard let vc = ProductDetailFactory.productDetailFromProduct(product) else { return }
        navigationController.pushViewController(vc, animated: true)

    }

    func openProduct(productId productId: String) {
        navigationController.showLoadingMessageAlert()
        productRepository.retrieve(productId) { [weak self] result in
            if let product = result.value {
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.openProduct(product: product)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized, .Forbidden, .TooManyRequests, .UserNotVerified:
                    message = LGLocalizedString.commonProductNotAvailable
                }
                self?.navigationController.dismissLoadingMessageAlert {
                    self?.navigationController.showAutoFadingOutMessageAlert(message)
                }
            }
        }
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
