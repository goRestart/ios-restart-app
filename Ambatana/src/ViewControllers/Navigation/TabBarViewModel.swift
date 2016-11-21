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


    var notificationsBadge = Variable<String?>(nil)
    var chatsBadge = Variable<String?>(nil)

    private let keyValueStorage: KeyValueStorage
    private let notificationsManager: NotificationsManager
    private let myUserRepository: MyUserRepository
    private var didAppearFirstTime: Bool
    private var featureFlags: FeatureFlags

    private let disposeBag = DisposeBag()

    
    // MARK: - View lifecycle

    convenience override init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance,
                  notificationsManager: NotificationsManager.sharedInstance,
                  myUserRepository: Core.myUserRepository, featureFlags: FeatureFlags.sharedInstance)
    }

    init(keyValueStorage: KeyValueStorage, notificationsManager: NotificationsManager, myUserRepository: MyUserRepository,
         featureFlags: FeatureFlags) {
        self.keyValueStorage = keyValueStorage
        self.notificationsManager = notificationsManager
        self.myUserRepository = myUserRepository
        self.featureFlags = featureFlags
        self.didAppearFirstTime = false
        super.init()
        setupRx()
    }

    func didAppear() {
        guard !didAppearFirstTime else { return }
        didAppearFirstTime = true
        guard featureFlags.freePostingMode != .Disabled && !keyValueStorage[.giveAwayTooltipAlreadyShown] else { return }

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


    // MARK: - Private methods

    private func setupRx() {
        notificationsManager.unreadMessagesCount.asObservable()
            .map { $0.flatMap { $0 > 0 ? String($0) : nil } }
            .bindTo(chatsBadge).addDisposableTo(disposeBag)

        Observable.combineLatest(myUserRepository.rx_myUser.asObservable(),
            notificationsManager.unreadNotificationsCount.asObservable(),
            resultSelector: { (myUser, count) in
                guard featureFlags.notificationsSection else { return nil }
                guard myUser != nil else { return String(1) }
                return count.flatMap { $0 > 0 ? String($0) : nil }
            }).bindTo(notificationsBadge).addDisposableTo(disposeBag)
    }
}
