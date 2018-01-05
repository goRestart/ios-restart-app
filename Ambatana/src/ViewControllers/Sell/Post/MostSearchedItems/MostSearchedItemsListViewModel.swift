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
    
    // TODO: This property will be a array of MostSearchedItem
    let mostSearchedItems: [String]
    
    
    // MARK: - Lifecycle
    
    init(featureFlags: FeatureFlaggeable, isSearchEnabled: Bool) {
        self.featureFlags = featureFlags
        self.isSearchEnabled = isSearchEnabled
        mostSearchedItems = ["item1", "item2", "item3", "item4", "item5", "item6", "item7", "item8", "item9", "item10",
                             "item11", "item12", "item13", "item14", "item15"]
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
    
    func itemAtIndex(_ index: Int) -> String {
        return mostSearchedItems[index]
    }
}
