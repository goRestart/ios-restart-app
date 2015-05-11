//
//  CLPostalAddressRetrievalService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import AddressBookUI
import CoreLocation

public class CLPostalAddressRetrievalService: PostalAddressRetrievalService {
    
    // iVars
    private var geocoder: CLGeocoder
    
    // MARK: - Lifecycle
    
    public init() {
        geocoder = CLGeocoder()
    }
    
    // MARK: - PostalAddressRetrievalService
    
    public func retrieveAddressForLocation(location: CLLocation, completion: PostalAddressRetrievalCompletion) {
        geocoder.reverseGeocodeLocation(location) { (placemarks: [AnyObject]!, error: NSError!) -> Void in
            
            // Error
            if let actualError = error {
                completion(address: nil, error: actualError)
            }
            else if let actualPlacemarks = placemarks as? [CLPlacemark] {
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
                completion(address: postalAddress, error: nil)
            }
        }
    }
}