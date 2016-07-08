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
    func vmShowChat(chatViewModel viewModel: OldChatViewModel)
    func vmShowResetPassword(changePasswordViewModel viewModel: ChangePasswordViewModel)
    func vmShowMainProducts(mainProductsViewModel viewModel: MainProductsViewModel)
    func isAtRootLevel() -> Bool
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

    func notificationsViewModel() -> NotificationsViewModel {
        return NotificationsViewModel()
    }

    func chatsViewModel() -> ChatGroupedViewModel {
        return ChatGroupedViewModel()
    }

    func profileViewModel() -> UserViewModel {
        return UserViewModel.myUserUserViewModel(.TabBar)
    }

    func sellButtonPressed() {
        navigator?.openSell(.SellButton, forceCamera: false)
    }
    
    func openSell(source: PostingSource, forceCamera: Bool) {
        navigator?.openSell(source, forceCamera: forceCamera)
    }

    func externalSwitchToTab(tab: Tab) {
        delegate?.vmSwitchToTab(tab, force: false)
    }
}
