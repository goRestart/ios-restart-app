//
//  CLPlacemark+Place.swift
//  LGCoreKit
//
//  Created by Dídac on 13/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import CoreLocation
import AddressBookUI

extension CLPlacemark {
    public func place() -> Place {

        var place = Place()
        
        place.name = self.name
        if let placemarkLocation = self.location {
            place.location = LGLocationCoordinates2D(coordinates: placemarkLocation.coordinate)
        }
        
        var postalAddress = PostalAddress(address: nil, city: self.locality, zipCode: self.postalCode, countryCode: self.ISOcountryCode, country: self.country)
        if let addressDict = self.addressDictionary {
            postalAddress.address = ABCreateStringWithAddressDictionary(addressDict, false)
        }
        
        place.postalAddress = postalAddress
        
        var resumedData = ""
        if let name = self.name {
            resumedData += name
        }
        if let city = self.locality {
            resumedData += ", \(city)"
        }
        if let zipCode = self.postalCode {
            resumedData += ", \(zipCode)"
        }
        if let country = self.country {
            resumedData += ", \(country)"
        }
        place.placeResumedData = resumedData
        
        return place
    }
}