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
    
    private let requester: ListingListRequester
    private let navigator: ListingsMapNavigator
    private let productFilter : ListingFilters
    private let featureFlags: FeatureFlaggeable
    private let locationManager: LocationManager
    
    let listingsVariable = Variable([Listing]())
    let isEmptyVariable = Variable(false)
    let isLoadingVariable = Variable(false)
    let mkAnnotationVariable = Variable([MKAnnotation]())
    
    init(requester: ListingListRequester,
         navigator:ListingsMapNavigator,
         locationManager: LocationManager,
         currentFilters: ListingFilters,
         featureFlags: FeatureFlaggeable) {
        self.requester = requester
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
        return productFilter.place?.location
    }
    
    func retrieve() {
        requester.retrieveFirstPage { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isLoadingVariable.value = true
            if let newListings = result.listingsResult.value {
                strongSelf.listingsVariable.value = newListings
                strongSelf.isEmptyVariable.value = newListings.isEmpty
                strongSelf.isLoadingVariable.value = false
                strongSelf.mkAnnotationVariable.value = newListings.annotations
            }
        }
    }
    
}

extension Listing {
    
    var type: MapAnnotationType {
        switch self {
        case .product, .car: return .general
        case .realEstate: return .realEstate
        }
    }
    
    var configuration: LGMapAnnotationConfiguration {
        return LGMapAnnotationConfiguration(location: location,
                                            title: name ?? "",
                                            type: type,
                                            isFeatured: featured ?? false)
    }
    
    var annotation: MKAnnotation {
        return LGMapAnnotation(configuration: configuration)
    }
    
}


private extension Array where Element == Listing {
    var annotations: [MKAnnotation] {
        return map { return $0.annotation }
    }
}
