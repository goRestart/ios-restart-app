//
//  PostalAddressRetrievalService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public enum PostalAddressRetrievalServiceError: ErrorType {
    case Network
    case Internal
}

public typealias PostalAddressRetrievalServiceResult = Result<Place, PostalAddressRetrievalServiceError>
public typealias PostalAddressRetrievalServiceCompletion = PostalAddressRetrievalServiceResult -> Void

public protocol PostalAddressRetrievalService {

    /**
        Retrieves the address for the given location.

        - parameter location: The location.
        - parameter completion: The completion closure.
    */
    func retrieveAddressForLocation(location: CLLocation, completion: PostalAddressRetrievalServiceCompletion?)
}
