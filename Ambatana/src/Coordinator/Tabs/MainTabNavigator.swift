//
//  MainTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol MainTabNavigator: TabNavigator {
    func openMainProduct(withSearchType searchType: SearchType, productFilters: ProductFilters)
    func showFilters(with productFilters: ProductFilters, filtersVMDataDelegate: FiltersViewModelDataDelegate?)
    func openLocationSelection()
}
