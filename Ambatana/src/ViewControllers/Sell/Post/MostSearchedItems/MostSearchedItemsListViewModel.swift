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
        navigator?.cancel()
    }
    
    func searchButtonAction(itemName: String) {
        //navigator?.openSearchFor(query: itemName)
    }
    
    func postButtonAction(item: LocalMostSearchedItem) {
        navigator?.openSell(mostSearchedItem: item)
    }
    
    
    // MARK: - Most Searched Items data
    
    func itemAtIndex(_ index: Int) -> LocalMostSearchedItem {
        return mostSearchedItems[index]
    }
}
