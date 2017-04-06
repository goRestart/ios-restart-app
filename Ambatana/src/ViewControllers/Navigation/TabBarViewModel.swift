//
//  TabBarViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class TabBarViewModel: BaseViewModel {
    weak var navigator: AppNavigator?

    var notificationsBadge = Variable<String?>(nil)
    var chatsBadge = Variable<String?>(nil)
    var favoriteBadge = Variable<String?>(nil)
    var hideScrollBanner = Variable<Bool>(true)

    private let keyValueStorage: KeyValueStorage
    private let notificationsManager: NotificationsManager
    private let myUserRepository: MyUserRepository
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
        super.init()
        setupRx()
        syncFeatureFlagsRXIfNeeded()
    }


    // MARK: - Public methods

    func sellButtonPressed() {
        navigator?.openSell(.sellButton)
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
        hideScrollBanner.value = timeout ? true : !featureFlags.hideTabBarOnFirstSessionV2
    }
}
