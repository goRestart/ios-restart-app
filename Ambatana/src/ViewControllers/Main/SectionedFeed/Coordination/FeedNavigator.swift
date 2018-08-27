//
//  File.swift
//  LetGo
//
//  Created by Facundo Menzella on 17/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

protocol FeedNavigator: class {
    func openMainListings(withSearchType searchType: SearchType, listingFilters: ListingFilters)
    func openFilters(withListingFilters listingFilters: ListingFilters,
                     filtersVMDataDelegate: FiltersViewModelDataDelegate?)
    func openLocationSelection(initialPlace: Place?, distanceRadius: Int?, locationDelegate: EditLocationDelegate)
    func showPushPermissionsAlert(withPositiveAction positiveAction: @escaping (() -> Void), negativeAction: @escaping (() -> Void))
    func openMap(requester: ListingListMultiRequester,
                 listingFilters: ListingFilters,
                 locationManager: LocationManager)
}
