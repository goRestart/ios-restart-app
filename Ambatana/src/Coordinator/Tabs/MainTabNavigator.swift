//
//  MainTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol MainTabNavigator: TabNavigator, FeedNavigator {
    func openMainListings(withSearchType searchType: SearchType,
                         listingFilters: ListingFilters)
	func openFilters(withListingFilters listingFilters: ListingFilters,
                     filtersVMDataDelegate: FiltersViewModelDataDelegate?)    
    func openLocationSelection(initialPlace: Place?,
                               distanceRadius: Int?,
                               locationDelegate: EditLocationDelegate)
    func openTaxonomyList(withViewModel viewModel: TaxonomiesViewModel)
    func openMostSearchedItems(source: PostingSource, enableSearch: Bool)
    func openLoginIfNeeded(infoMessage: String, then loggedAction: @escaping (() -> Void))
    func openSearchAlertsList()
    func openMap(with listingFilters: ListingFilters, locationManager: LocationManager)
}
