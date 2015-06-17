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
    
    public func retrieveAddressForLocation(location: CLLocation, result: PostalAddressRetrievalServiceResult) {
        geocoder.reverseGeocodeLocation(location) { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            // Success
            if let actualPlacemarks = placemarks as? [CLPlacemark] {
                var postalAddress: PostalAddress = PostalAddress()
                if !actualPlacemarks.isEmpty {
                    let placemark = actualPlacemarks.last!
                    postalAddress.city = placemark.locality
                    postalAddress.countryCode = placemark.ISOcountryCode
                    postalAddress.zipCode = placemark.postalCode
                    if let addressDict = placemark.addressDictionary {
                        postalAddress.address = ABCreateStringWithAddressDictionary(addressDict, false)
                    }
                }
                result(Result<PostalAddress, PostalAddressRetrievalServiceError>.success(postalAddress))
            }
            // Error
            else if let actualError = error {
                result(Result<PostalAddress, PostalAddressRetrievalServiceError>.failure(.Network))
            }
            else {
                result(Result<PostalAddress, PostalAddressRetrievalServiceError>.failure(.Internal))
            }
        }
    }
}