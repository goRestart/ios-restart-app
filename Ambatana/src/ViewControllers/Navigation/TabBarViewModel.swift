//
//  TabBarViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol TabBarViewModelDelegate: BaseViewModelDelegate {
    func vmSwitchToTab(tab: Tab, force: Bool)
    func vmShowProduct(productVC: UIViewController)
    func vmShowUser(userViewModel viewModel: UserViewModel)
    func vmShowChat(chatViewModel viewModel: ChatViewModel)
    func vmShowResetPassword(changePasswordViewModel viewModel: ChangePasswordViewModel)
    func vmShowMainProducts(mainProductsViewModel viewModel: MainProductsViewModel)
    func isAtRootLevel() -> Bool
    func isShowingConversationForConversationData(data: ConversationData) -> Bool
}


class TabBarViewModel: BaseViewModel {
    weak var navigator: AppNavigator?
    weak var delegate: TabBarViewModelDelegate?


    // MARK: - View lifecycle

    override init() {
        super.init()
    }


    // MARK: - Public methods

    func mainProductsViewModel() -> MainProductsViewModel {
        return MainProductsViewModel()
    }

    func categoriesViewModel() -> CategoriesViewModel {
        return CategoriesViewModel()
    }

    func chatsViewModel() -> ChatGroupedViewModel {
        return ChatGroupedViewModel()
    }

    func profileViewModel() -> UserViewModel {
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
        navigator?.openSellIfLoggedIn()
    }

    func externalSwitchToTab(tab: Tab) {
        delegate?.vmSwitchToTab(tab, force: false)
    }
}
