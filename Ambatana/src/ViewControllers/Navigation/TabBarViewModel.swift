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
    func vmShowTooltipAtSellButtonWithText(text: NSAttributedString)
}


class TabBarViewModel: BaseViewModel {
    weak var navigator: AppNavigator?
    weak var delegate: TabBarViewModelDelegate?

    private let keyValueStorage: KeyValueStorage
    private var didAppearFirstTime: Bool

    
    // MARK: - View lifecycle

    override init() {
        keyValueStorage = KeyValueStorage.sharedInstance
        didAppearFirstTime = false
        super.init()
    }

    func didAppear() {
        guard !didAppearFirstTime else { return }
        didAppearFirstTime = true
        guard FeatureFlags.freePostingMode != .Disabled && !keyValueStorage[.giveAwayTooltipAlreadyShown] else { return }

        var newTextAttributes = [String : AnyObject]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let newText = NSAttributedString(string: LGLocalizedString.commonNew, attributes: newTextAttributes)

        var titleTextAttributes = [String : AnyObject]()
        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let titleText = NSAttributedString(string: LGLocalizedString.tabBarGiveAwayTooltip, attributes: titleTextAttributes)

        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.appendAttributedString(NSAttributedString(string: " "))
        fullTitle.appendAttributedString(titleText)

        delegate?.vmShowTooltipAtSellButtonWithText(fullTitle)
    }


    // MARK: - Public methods

    func tooltipDismissed() {
        keyValueStorage[.giveAwayTooltipAlreadyShown] = true
    }

    func sellButtonPressed() {
        navigator?.openSell(.SellButton)
    }

    func giveAwayButtonPressed() {
        navigator?.openSell(.GiveAwayButton)
    }

    func userRating(source: RateUserSource, data: RateUserData) {
        navigator?.openUserRating(source, data: data)
    }

    func externalSwitchToTab(tab: Tab) {
        delegate?.vmSwitchToTab(tab, force: false)
    }
}
