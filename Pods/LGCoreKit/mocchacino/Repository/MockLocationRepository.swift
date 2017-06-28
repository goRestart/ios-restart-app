//
//  MockPostalAddressRetrievalRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 20/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

open class MockLocationRepository: LocationRepository {

    public var suggestionsResult: SuggestionsLocationRepositoryResult!
    public var postalAddressResult: PostalAddressLocationRepositoryResult!
    public var ipLookupLocationResult: IPLookupLocationRepositoryResult!
    
    
    // MARK: - Lifecycle
    
    required public init() {
        
    }
    
    // MARK: - PostalAddressRetrievalRepository
    
    public func retrieveAddressForLocation(_ location: LGLocationCoordinates2D, completion: PostalAddressLocationRepositoryCompletion?) {
        delay(result: postalAddressResult, completion: completion)
    }
    
    public func retrieveAddressForLocation(_ searchText: String, completion: SuggestionsLocationRepositoryCompletion?) {
        delay(result: suggestionsResult, completion: completion)
    }
    
    public func retrieveLocationWithCompletion(_ completion: IPLookupLocationRepositoryCompletion?) {
        delay(result: ipLookupLocationResult, completion: completion)
    }
}
 
