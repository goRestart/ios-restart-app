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
    
    var shouldShowRealEstateTooltip: Bool {
        return featureFlags.realEstateEnabled.isActive && featureFlags.realEstateImprovements.isActive && !keyValueStorage[.realEstateTooltipSellButtonAlreadyShown]
    }

    private let notificationsManager: NotificationsManager
    private let myUserRepository: MyUserRepository
    private let keyValueStorage: KeyValueStorage
    private let featureFlags: FeatureFlaggeable
    
    private let disposeBag = DisposeBag()

    
    // MARK: - View lifecycle

    convenience override init() {
        self.init(notificationsManager: LGNotificationsManager.sharedInstance,
                  myUserRepository: Core.myUserRepository,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(notificationsManager: NotificationsManager,
         myUserRepository: MyUserRepository,
         keyValueStorage: KeyValueStorage,
         featureFlags: FeatureFlaggeable) {
        self.notificationsManager = notificationsManager
        self.myUserRepository = myUserRepository
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        super.init()
        setupRx()
    }


    // MARK: - Public methods

    func sellButtonPressed() {
        navigator?.openSell(source: .sellButton, postCategory: nil)
    }
    
    func expandableButtonPressed(listingCategory: ListingCategory) {
        navigator?.openSell(source: .sellButton, postCategory: listingCategory.postCategory)
    }
    
    
    func realEstateTooltipText() -> NSMutableAttributedString {
        var newTextAttributes = [String : Any]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)
        
        let newText = NSAttributedString(string: LGLocalizedString.commonNew, attributes: newTextAttributes)
        
        var titleTextAttributes = [String : Any]()
        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.white
        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)
        
        let titleText = NSAttributedString(string: LGLocalizedString.realEstateTooltipSellButton, attributes: titleTextAttributes)
        
        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.append(NSAttributedString(string: " "))
        fullTitle.append(titleText)
        
        return fullTitle
    }
    
    func tooltipDismissed() {
        guard shouldShowRealEstateTooltip else { return }
        keyValueStorage[.realEstateTooltipSellButtonAlreadyShown] = true
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
