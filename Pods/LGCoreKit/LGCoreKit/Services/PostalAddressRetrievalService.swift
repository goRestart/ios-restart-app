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
    
//    geocoder.reverseGeocodeLocation(location) { (placemarks: [AnyObject]!, error: NSError!) -> Void in
//    if placemarks?.count > 0 {
//    
//    }
//    
//    if let actualPlacemarks = placemarks as? [CLPlacemark] {
//    if !actualPlacemarks.isEmpty {
//    
//    }
//    }
//    }
    
    
    //            { (placemarks, error) -> Void in
    //                if placemarks?.count > 0 {
    //                    var addressString = ""
    //
    //                    if let placemark = placemarks?.first as? CLPlacemark {
    //                        // extract elements and update user.
    //                        if placemark.locality != nil {
    //                            productObject["city"] = placemark.locality
    //                            ConfigurationManager.sharedInstance.userLocation = placemark.locality
    //                        }
    //                        if placemark.postalCode != nil { productObject["zip_code"] = placemark.postalCode }
    //                        if placemark.ISOcountryCode != nil { productObject["country_code"] = placemark.ISOcountryCode }
    //                        if placemark.addressDictionary != nil {
    //                            addressString = ABCreateStringWithAddressDictionary(placemark.addressDictionary, false)
    //                            productObject["address"] = addressString
    //                        }
    //                    }
    //                }
}
