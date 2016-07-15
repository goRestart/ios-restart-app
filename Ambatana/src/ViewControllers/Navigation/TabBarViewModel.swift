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
//        navigator?.openSell(.SellButton)


        //TODO: ⚠️⚠️⚠️ REMOVE!!! JUST TO TEST!! ⚠️⚠️⚠️
        guard let myUser = Core.myUserRepository.myUser, data = RateUserData(user: myUser) else { return }
        navigator?.openUserRating(data)
    }

    func sellFromBannerCell(designType: String) {
        navigator?.openSell(.BannerCell(designType: designType))
    }

    func userRating(data: RateUserData) {
        navigator?.openUserRating(data)
    }

    func externalSwitchToTab(tab: Tab) {
        delegate?.vmSwitchToTab(tab, force: false)
    }
}
