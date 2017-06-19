//
//  MockPostalAddressRetrievalService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 20/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

open class MockPostalAddressRetrievalService: MockBaseService<Place, PostalAddressRetrievalServiceError>, PostalAddressRetrievalService {

    // MARK: - Lifecycle
    
    public required init(value: Place) {
        super.init(value: value)
    }
    
    public required init(error: PostalAddressRetrievalServiceError) {
        super.init(error: error)
    }
    
    // MARK: - PostalAddressRetrievalService
    
    public func retrieveAddressForLocation(_ location: LGLocationCoordinates2D, completion: PostalAddressRetrievalServiceCompletion?) {
        delay(result: result, completion: completion)
    }
}
