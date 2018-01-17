//
//  MostSearchedItemsListViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 03/01/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

class MostSearchedItemsListViewModel: BaseViewModel {
    
    weak var navigator: PostListingNavigator?
    let isSearchEnabled: Bool
    
    fileprivate let featureFlags: FeatureFlaggeable
    
    let mostSearchedItems: [LocalMostSearchedItem]
    
    
    // MARK: - Lifecycle
    
    init(featureFlags: FeatureFlaggeable, isSearchEnabled: Bool) {
        self.featureFlags = featureFlags
        self.isSearchEnabled = isSearchEnabled
        mostSearchedItems = LocalMostSearchedItem.allValues
        super.init()
    }
    
    convenience init(isSearchEnabled: Bool) {
        self.init(featureFlags: FeatureFlags.sharedInstance,
                  isSearchEnabled: isSearchEnabled)
    }
    
    
    // MARK: - Navigation
    
    func closeButtonPressed() {
        navigator?.cancelPostListing()
    }
    
    
    // MARK: - Most Searched Items data
    
    func itemAtIndex(_ index: Int) -> LocalMostSearchedItem {
        return mostSearchedItems[index]
    }
}
