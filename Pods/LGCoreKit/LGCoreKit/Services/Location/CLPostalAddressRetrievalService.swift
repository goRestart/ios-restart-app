//
//  CLPostalAddressRetrievalService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import AddressBookUI
import CoreLocation
import Result

public class CLPostalAddressRetrievalService: PostalAddressRetrievalService {
    
    // iVars
    private var geocoder: CLGeocoder
    
    // MARK: - Lifecycle
    
    public init() {
        geocoder = CLGeocoder()
    }
    
    // MARK: - PostalAddressRetrievalService
    
    public func retrieveAddressForLocation(location: CLLocation, result: PostalAddressRetrievalServiceResult?) {
        geocoder.reverseGeocodeLocation(location) { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            // Success
            if let actualPlacemarks = placemarks as? [CLPlacemark] {
                var postalAddress: PostalAddress = PostalAddress()
                var place = Place()
                if !actualPlacemarks.isEmpty {
                    let placemark = actualPlacemarks.last!
                    place = placemark.place()
                }
                result?(Result<Place, PostalAddressRetrievalServiceError>.success(place))
            }
            // Error
            else if let actualError = error {
                result?(Result<Place, PostalAddressRetrievalServiceError>.failure(.Network))
            }
            else {
                result?(Result<Place, PostalAddressRetrievalServiceError>.failure(.Internal))
            }
        }
    }
}