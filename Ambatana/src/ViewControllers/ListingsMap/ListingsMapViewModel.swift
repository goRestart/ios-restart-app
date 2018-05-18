//
//  ListingsMapViewModel.swift
//  LetGo
//
//  Created by Tomas Cobo on 30/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import RxSwift
import RxCocoa
import MapKit

final class ListingsMapViewModel: BaseViewModel {
    
    private let navigator: TabNavigator
    private var productFilter : ListingFilters
    private let featureFlags: FeatureFlaggeable
    private let locationManager: LocationManager

    let listingsVariable: Variable<[Listing]?> = Variable(nil)

    let isLoading = Variable(false)
    let errorMessage = Variable<String?>(nil)
    
    init(navigator: TabNavigator,
         locationManager: LocationManager,
         currentFilters: ListingFilters,
         featureFlags: FeatureFlaggeable) {
        self.navigator = navigator
        self.locationManager = locationManager
        self.productFilter = currentFilters
        self.featureFlags = featureFlags
        super.init()
        retrieve(with: currentFilters)
    }
    
    var location: LGLocationCoordinates2D? {
        if let filterLocation = productFilter.place?.location {
            return filterLocation
        } else if let positionCoordinate = locationManager.currentLocation?.coordinate {
            return LGLocationCoordinates2D(coordinates: positionCoordinate)
        }
        return nil
    }
    
    var accuracy: Double {
        return productFilter.selectedCategories.first?.mapAccuracy ?? Constants.nonAccurateRegionRadius
    }
    
    private func retrieve(with filters: ListingFilters) {
        isLoading.value = true
        let requester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                            queryString: nil,
                                                                            itemsPerPage: 50,
                                                                            carSearchActive: featureFlags.searchCarsIntoNewBackend.isActive)
        requester.retrieveFirstPage { [weak self] result in
            guard let strongSelf = self else { return }
            if let error = result.listingsResult.error {
                strongSelf.showMap(error: error)
            } else if let newListings = result.listingsResult.value {
                strongSelf.listingsVariable.value = newListings
            }
            strongSelf.isLoading.value = false
        }
    }
    
    private func resetMap() {
        listingsVariable.value = nil
    }
    
    private func showMap(error: RepositoryError) {
        var errorString: String? = nil
            switch error {
            case .network:
                errorString = LGLocalizedString.toastNoNetwork
            case .internalError, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .wsChatError, .searchAlertError:
                errorString = LGLocalizedString.toastErrorInternal
            case .unauthorized:
                errorString = nil
            }
        errorMessage.value = errorString
    }
    
    func update(with location: LGLocationCoordinates2D, radius: Int) {
        resetMap()
        var filter = productFilter
        filter.place?.location = location
        filter.distanceRadius = radius
        retrieve(with: filter)
    }
    
    func listing(at index: Int) -> Listing? {
        return listingsVariable.value?[safeAt: index]
    }
    
    func tags(at index: Int) -> [String] {
        return listing(at: index)?.tags(postingFlowType: featureFlags.postingFlowType) ?? []
    }
    
    func open(_ listingData: ListingDetailData) {
        navigator.openListing(listingData, source: .filter, actionOnFirstAppear: .nonexistent)
    }
    
}
