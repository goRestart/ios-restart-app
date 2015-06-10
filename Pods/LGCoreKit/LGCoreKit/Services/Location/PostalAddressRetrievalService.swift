//
//  PostalAddressRetrievalService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public protocol PostalAddressRetrievalService {
    
    /**
        Retrieves the address for the given location.
    
        :param: location The location.
        :param: completion The completion closure.
    */
    func retrieveAddressForLocation(location: CLLocation, completion: PostalAddressRetrievalCompletion)
}
