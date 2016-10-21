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

    func sellButtonPressed() {
        // TODO: Here we have to check AB test and send diferent source in case two buttons. // ABIOS-1725
        navigator?.openSell(.SellButton)
    }
    
    func userRating(source: RateUserSource, data: RateUserData) {
        navigator?.openUserRating(source, data: data)
    }

    func externalSwitchToTab(tab: Tab) {
        delegate?.vmSwitchToTab(tab, force: false)
    }
}
