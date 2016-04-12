//
//  TabBarViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol TabBarViewModelDelegate: BaseViewModelDelegate {
    func vmSwitchToTab(tab: Tab)
    func vmShowProduct(productViewModel viewModel: ProductViewModel)
    func vmShowUser(userViewModel viewModel: UserViewModel)
    func vmShowChat(chatViewModel viewModel: ChatViewModel)
}


class TabBarViewModel: BaseViewModel {

    weak var delegate: TabBarViewModelDelegate?

    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let myUserRepository: MyUserRepository
    private let sessionManager: SessionManager
    private let chatRepository: OldChatRepository


    // MARK: - View lifecycle

    convenience override init() {
        self.init(productRepository: Core.productRepository, userRepository: Core.userRepository,
                  myUserRepository: Core.myUserRepository, sessionManager: Core.sessionManager,
                  chatRepository: Core.oldChatRepository)
    }

    init(productRepository: ProductRepository, userRepository: UserRepository, myUserRepository: MyUserRepository,
         sessionManager: SessionManager, chatRepository: OldChatRepository) {
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.myUserRepository = myUserRepository
        self.sessionManager = sessionManager
        self.chatRepository = chatRepository
    }


    // MARK: - Public methods

    func viewControllerForTab(tab: Tab) -> UIViewController? {
        switch tab {
        case .Home:
            return MainProductsViewController()
        case .Categories:
            return CategoriesViewController()
        case .Sell:
            return nil
        case .Chats:
            return ChatGroupedViewController()
        case .Profile:
            let viewModel = UserViewModel.myUserUserViewModel(.TabBar)
            return UserViewController(viewModel: viewModel)
        }
    }

    func openProductWithId(productId: String) {
        delegate?.vmShowLoading(nil)

        productRepository.retrieve(productId) { [weak self] result in
            if let product = result.value {
                self?.delegate?.vmHideLoading(nil) { [weak self] in
                    let viewModel = ProductViewModel(product: product, thumbnailImage: nil)
                    self?.delegate?.vmShowProduct(productViewModel: viewModel)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized:
                    message = LGLocalizedString.commonProductNotAvailable
                }
                self?.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            }
        }
    }

    func openUserWithId(userId: String) {
        // If opening my own user, just go to the profile tab
        if let myUserId = myUserRepository.myUser?.objectId where myUserId == userId && sessionManager.loggedIn {
            delegate?.vmSwitchToTab(.Profile)
            return
        }

        delegate?.vmShowLoading(nil)

        userRepository.show(userId) { [weak self] result in
            if let user = result.value {
                self?.delegate?.vmHideLoading(nil) { [weak self] in
                    let viewModel = UserViewModel(user: user, source: .TabBar)
                    self?.delegate?.vmShowUser(userViewModel: viewModel)
                }
            } else if let error = result.error {
                let message: String
                switch error {
                case .Network:
                    message = LGLocalizedString.commonErrorConnectionFailed
                case .Internal, .NotFound, .Unauthorized:
                    message = LGLocalizedString.commonUserNotAvailable
                }
                self?.delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            }
        }
    }

    func openChatWithProductId(productId: String, buyerId: String) {
        delegate?.vmShowLoading(nil)

        chatRepository.retrieveMessagesWithProductId(productId, buyerId: buyerId, page: 0,
            numResults: Constants.numMessagesPerPage) { [weak self] result  in
                self?.processChatResult(result)
        }
    }

    func openChatWithConversationId(conversationId: String) {
        delegate?.vmShowLoading(nil)

        chatRepository.retrieveMessagesWithConversationId(conversationId, page: 0,
            numResults: Constants.numMessagesPerPage) { [weak self] result in
                self?.processChatResult(result)
        }
    }

    private func processChatResult(result: ChatResult) {
        if let chat = result.value {
            delegate?.vmHideLoading(nil) { [weak self] in
                guard let viewModel = ChatViewModel(chat: chat) else { return }
                self?.delegate?.vmShowChat(chatViewModel: viewModel)
            }
        } else if let error = result.error {
            let message: String
            switch error {
            case .Network:
                message = LGLocalizedString.commonErrorConnectionFailed
            case .Internal, .NotFound, .Unauthorized:
                message = LGLocalizedString.commonChatNotAvailable
            }
            delegate?.vmHideLoading(message, afterMessageCompletion: nil)
        }
    }

}