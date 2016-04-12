//
//  TabBarViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol TabBarViewModelDelegate: BaseViewModelDelegate {
    func vmSwitchToTab(tab: Tab, force: Bool)
    func vmShowProduct(productViewModel viewModel: ProductViewModel)
    func vmShowUser(userViewModel viewModel: UserViewModel)
    func vmShowChat(chatViewModel viewModel: ChatViewModel)
    func vmShowResetPassword(changePasswordViewModel viewModel: ChangePasswordViewModel)
    func vmShowMainProducts(mainProductsViewModel viewModel: MainProductsViewModel)
    func vmShowSell()
    func isAtRootLevel() -> Bool
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

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarViewModel.logout(_:)),
                                                         name: SessionManager.Notification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarViewModel.kickedOut(_:)),
                                                         name: SessionManager.Notification.KickedOut.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarViewModel.askUserToUpdateLocation),
                                                         name: LocationManager.Notification.MovedFarFromSavedManualLocation.rawValue, object: nil)
    }

    // MARK: - Public methods

    var mainProductsViewModel: MainProductsViewModel {
        return MainProductsViewModel()
    }

    var categoriesViewModel: CategoriesViewModel {
        return CategoriesViewModel()
    }

    var chatsViewModel: ChatGroupedViewModel {
        return ChatGroupedViewModel()
    }

    var profileViewModel: UserViewModel {
        return UserViewModel.myUserUserViewModel(.TabBar)
    }

    func shouldSelectTab(tab: Tab) -> Bool {
        var isLogInRequired = false
        var loginSource: EventParameterLoginSourceValue?

        switch tab {
        case .Home, .Categories:
            break
        case .Sell:
            // Do not allow selecting Sell (as we've a sell button over sell button tab)
            return false
        case .Chats:
            loginSource = .Chats
            isLogInRequired = !Core.sessionManager.loggedIn
        case .Profile:
            loginSource = .Profile
            isLogInRequired = !Core.sessionManager.loggedIn
        }
        // If logged present the selected VC, otherwise present the login VC (and if successful the selected  VC)
        if let actualLoginSource = loginSource where isLogInRequired {
            delegate?.ifLoggedInThen(actualLoginSource, loggedInAction: { [weak self] in
                    self?.delegate?.vmSwitchToTab(tab, force: true)
                },
                elsePresentSignUpWithSuccessAction: { [weak self] in
                    self?.delegate?.vmSwitchToTab(tab, force: false)
                })
        }

        return !isLogInRequired
    }

    func sellButtonPressed() {
        delegate?.vmShowSell()
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
            delegate?.vmSwitchToTab(.Profile, force: false)
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

    func openResetPassword(token: String) {
        let viewModel = ChangePasswordViewModel(token: token)
        delegate?.vmShowResetPassword(changePasswordViewModel: viewModel)
    }

    func openSearch(query: String, categoriesString: String?) {
        var filters = ProductFilters()
        if let catString = categoriesString {
            filters.selectedCategories = ProductCategory.categoriesFromString(catString)
        }
        let viewModel = MainProductsViewModel(searchString: query, filters: filters)
        delegate?.vmShowMainProducts(mainProductsViewModel: viewModel)
    }


    // MARK: - Private methods

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


    // MARK: > Notifications
    dynamic private func logout(notification: NSNotification) {
        delegate?.vmSwitchToTab(.Home, force: false)
    }

    dynamic private func kickedOut(notification: NSNotification) {
        delegate?.vmShowAutoFadingMessage(LGLocalizedString.toastErrorInternal, completion: nil)
    }

    dynamic private func askUserToUpdateLocation() {
        guard let isAtRoot = delegate?.isAtRootLevel() where isAtRoot else { return }

        let yesAction = UIAction(interface: .StyledText(LGLocalizedString.commonOk, .Default)) {
            Core.locationManager.setAutomaticLocation(nil)
        }
        let noAction = UIAction(interface: .StyledText(LGLocalizedString.commonCancel, .Cancel)) { [weak self] in
            let updateAction = UIAction(interface:
                    .StyledText(LGLocalizedString.changeLocationConfirmUpdateButton, .Default)) {
                Core.locationManager.setAutomaticLocation(nil)
            }
            self?.delegate?.vmShowAlert(nil, message: LGLocalizedString.changeLocationRecommendUpdateLocationMessage,
                                        cancelLabel:"",  actions: [updateAction])
        }
        delegate?.vmShowAlert(nil, message: LGLocalizedString.changeLocationAskUpdateLocationMessage,
                              actions: [noAction,yesAction])


        // We should ask only one time
        NSNotificationCenter.defaultCenter().removeObserver(self,
                        name: LocationManager.Notification.MovedFarFromSavedManualLocation.rawValue, object: nil)
    }
}