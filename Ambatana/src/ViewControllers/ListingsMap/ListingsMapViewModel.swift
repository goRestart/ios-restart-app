//
//  ListingsMapViewModel.swift
//  LetGo
//
//  Created by Tomas Cobo on 30/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit

final class ListingsMapViewModel: BaseViewModel {

    private let navigator: ListingsMapNavigator
    private let productFilter : ListingFilters
    private let featureFlags: FeatureFlaggeable
    private let locationManager: LocationManager

    init(navigator:ListingsMapNavigator,
         locationManager: LocationManager,
         currentFilters: ListingFilters,
         featureFlags: FeatureFlaggeable) {
        self.navigator = navigator
        self.locationManager = locationManager
        self.productFilter = currentFilters
        self.featureFlags = featureFlags
        super.init()
    }
    
    func close() {
        navigator.closeMap()
    }
    
    var location: LGLocationCoordinates2D? {
        return locationManager.currentLocation?.location
    }
    
}
