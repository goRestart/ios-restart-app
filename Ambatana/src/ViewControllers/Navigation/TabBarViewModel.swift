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
    func vmSwitchToTab(_ tab: Tab, force: Bool, completion: (() -> ())?)
    func vmShowTooltipAtSellButtonWithText(_ text: NSAttributedString)
}


class TabBarViewModel: BaseViewModel {
    weak var navigator: AppNavigator?
    weak var delegate: TabBarViewModelDelegate?


    var notificationsBadge = Variable<String?>(nil)
    var chatsBadge = Variable<String?>(nil)
    var favoriteBadge = Variable<String?>(nil)
    var hideScrollBanner = Variable<Bool>(false)

    private let keyValueStorage: KeyValueStorage
    private let notificationsManager: NotificationsManager
    private let myUserRepository: MyUserRepository
    private var didAppearFirstTime: Bool
    private var featureFlags: FeatureFlaggeable
    private let abTestSyncTimeout: TimeInterval

    private let disposeBag = DisposeBag()
    
    var shouldSetupScrollBanner: Bool {
        return keyValueStorage[.sessionNumber] == 1
    }

    
    // MARK: - View lifecycle

    convenience override init() {
        self.init(keyValueStorage: KeyValueStorage.sharedInstance,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  myUserRepository: Core.myUserRepository, featureFlags: FeatureFlags.sharedInstance, syncTimeout: Constants.abTestSyncTimeout)
    }

    init(keyValueStorage: KeyValueStorage, notificationsManager: NotificationsManager, myUserRepository: MyUserRepository,
         featureFlags: FeatureFlaggeable, syncTimeout: TimeInterval) {
        self.keyValueStorage = keyValueStorage
        self.notificationsManager = notificationsManager
        self.myUserRepository = myUserRepository
        self.featureFlags = featureFlags
        self.abTestSyncTimeout = syncTimeout
        self.didAppearFirstTime = false
        super.init()
        setupRx()
        syncFeatureFlagsRXIfNeeded()
    }

    func didAppear() {
        guard !didAppearFirstTime else { return }
        didAppearFirstTime = true
        guard featureFlags.freePostingModeAllowed && !keyValueStorage[.giveAwayTooltipAlreadyShown] else { return }

        var newTextAttributes = [String : Any]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let newText = NSAttributedString(string: LGLocalizedString.commonNew, attributes: newTextAttributes)

        var titleTextAttributes = [String : Any]()
        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.white
        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let titleText = NSAttributedString(string: LGLocalizedString.tabBarGiveAwayTooltip, attributes: titleTextAttributes)

        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.append(NSAttributedString(string: " "))
        fullTitle.append(titleText)

        delegate?.vmShowTooltipAtSellButtonWithText(fullTitle)
    }


    // MARK: - Public methods

    func tooltipDismissed() {
        keyValueStorage[.giveAwayTooltipAlreadyShown] = true
    }

    func sellButtonPressed() {
        navigator?.openSell(.sellButton)
    }

    func userRating(_ source: RateUserSource, data: RateUserData) {
        navigator?.openUserRating(source, data: data)
    }

    func externalSwitchToTab(_ tab: Tab, completion: (() -> ())?) {
        delegate?.vmSwitchToTab(tab, force: false, completion: completion)
    }
    
    func tabBarChangeVisibility(hidden: Bool) {
        guard hidden else { return }
        hideScrollBanner.value = hidden
    }


    // MARK: - Private methods

    private func setupRx() {
        notificationsManager.unreadMessagesCount.asObservable()
            .map { $0.flatMap { $0 > 0 ? String($0) : nil } }
            .bindTo(chatsBadge).addDisposableTo(disposeBag)
        
        Observable.combineLatest(myUserRepository.rx_myUser,
            notificationsManager.unreadNotificationsCount.asObservable(),
            resultSelector: { (myUser, count) -> String? in
                guard myUser != nil else { return String(1) }
                return count.flatMap { $0 > 0 ? String($0) : nil }
            }).bindTo(notificationsBadge).addDisposableTo(disposeBag)
    }
    
    private func syncFeatureFlagsRXIfNeeded() {
        guard shouldSetupScrollBanner else { return }
        featureFlags.syncedData.filter{ $0 }.take(1).timeout(abTestSyncTimeout, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self ] _ in self?.setScrollBannerVisibility(timeout: false) },
                       onError: { [weak self] _ in self?.setScrollBannerVisibility(timeout: true) })
            .addDisposableTo(disposeBag)
    }

    private func setScrollBannerVisibility(timeout: Bool) {
        hideScrollBanner.value = timeout ? true : !featureFlags.hideTabBarOnFirstSession
    }
}
