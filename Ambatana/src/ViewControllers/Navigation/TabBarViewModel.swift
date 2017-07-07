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

    private let notificationsManager: NotificationsManager
    private let myUserRepository: MyUserRepository

    private let disposeBag = DisposeBag()

    
    // MARK: - View lifecycle

    convenience override init() {
        self.init(notificationsManager: LGNotificationsManager.sharedInstance,
                  myUserRepository: Core.myUserRepository)
    }

    init(notificationsManager: NotificationsManager, myUserRepository: MyUserRepository) {
        self.notificationsManager = notificationsManager
        self.myUserRepository = myUserRepository
        super.init()
        setupRx()
    }


    // MARK: - Public methods

    func sellButtonPressed() {
        navigator?.openSell(.sellButton)
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
}
