//
//  PostalAddressRetrievalService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public enum PostalAddressRetrievalServiceError {
    case Network
    case Internal
}

public typealias PostalAddressRetrievalServiceResult = (Result<PostalAddress, PostalAddressRetrievalServiceError>) -> Void

public protocol PostalAddressRetrievalService {
    
    /**
        Retrieves the address for the given location.
    
        :param: location The location.
        :param: result The closure containing the result.
    */
    func retrieveAddressForLocation(location: CLLocation, result: PostalAddressRetrievalServiceResult)
}
