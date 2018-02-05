//
//  MostSearchedItemsListViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 03/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

enum MostSearchedItemsSource {
    case categoriesHeader
    case userProfile
    case cameraBadge
    case card
}

class MostSearchedItemsListViewModel: BaseViewModel {
    
    weak var navigator: MostSearchedItemsNavigator?
    let isSearchEnabled: Bool
    
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let keyValueStorage: KeyValueStorage
    
    let mostSearchedItems: [LocalMostSearchedItem]
    
    
    // MARK: - Lifecycle
    
    convenience init(isSearchEnabled: Bool) {
        self.init(featureFlags: FeatureFlags.sharedInstance,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  isSearchEnabled: isSearchEnabled)
    }
    
    init(featureFlags: FeatureFlaggeable,
         notificationsManager: NotificationsManager,
         keyValueStorage: KeyValueStorage,
         isSearchEnabled: Bool) {
        self.featureFlags = featureFlags
        self.keyValueStorage = keyValueStorage
        self.isSearchEnabled = isSearchEnabled
        mostSearchedItems = LocalMostSearchedItem.allValues
        super.init()
        
        let isShowingSellBadge = featureFlags.mostSearchedDemandedItems == .cameraBadge &&
            !keyValueStorage[.mostSearchedItemsCameraBadgeAlreadyShown]
        if isShowingSellBadge {
            keyValueStorage[.mostSearchedItemsCameraBadgeAlreadyShown] = true
            notificationsManager.clearNewSellFeatureIndicator()
        }
    }
    
    
    // MARK: - Navigation
    
    func closeButtonPressed() {
        navigator?.cancel()
    }
    
    func searchButtonAction(listingTitle: String) {
        navigator?.openSearchFor(listingTitle: listingTitle)
    }
    
    func postButtonAction(item: LocalMostSearchedItem) {
        navigator?.openSell(mostSearchedItem: item)
    }
    
    
    // MARK: - Most Searched Items data
    
    func itemAtIndex(_ index: Int) -> LocalMostSearchedItem {
        return mostSearchedItems[index]
    }
}
