//
//  CLPlacemark+Place.swift
//  LGCoreKit
//
//  Created by Dídac on 13/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import Contacts
import CoreLocation
import AddressBookUI

extension CLPlacemark {
    public func place() -> Place {

        var place = Place()

        place.name = self.name
        if let placemarkLocation = self.location {
            place.location = LGLocationCoordinates2D(coordinates: placemarkLocation.coordinate)
        }

        let address = postalAddressStringFromAddressDictionary(self.addressDictionary, addCountryName: false)
        let postalAddress = PostalAddress(address: address, city: self.locality, zipCode: self.postalCode,
            countryCode: self.ISOcountryCode, country: self.country)

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

    /**
    Returns a localized string from postal address dictionary.
    - parameter addressDict: A postal address dictionary.
    - returns: A localized postal address string.
    */
    private func postalAddressStringFromAddressDictionary(addressDict: Dictionary<NSObject,AnyObject>?,
        addCountryName: Bool) -> String? {
            guard let addressDict = addressDict else { return nil }
            let addressString: String
            if #available(iOS 9.0, *) {
                let address = CNMutablePostalAddress()
                address.street = addressDict[kABPersonAddressStreetKey] as? String ?? ""
                address.state = addressDict[kABPersonAddressStateKey] as? String ?? ""
                address.postalCode = addressDict["ZIP"] as? String ?? ""
                address.city = addressDict[kABPersonAddressCityKey] as? String ?? ""
                address.ISOCountryCode = addressDict[kABPersonAddressCountryCodeKey] as? String ?? ""
                if addCountryName {
                    address.country = addressDict[kABPersonAddressCountryKey] as? String ?? ""
                }
                addressString = CNPostalAddressFormatter.stringFromPostalAddress(address, style: .MailingAddress)
            } else {
                addressString = ABCreateStringWithAddressDictionary(addressDict, addCountryName)
            }
            return addressString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

