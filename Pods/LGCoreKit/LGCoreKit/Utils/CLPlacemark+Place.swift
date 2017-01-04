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

        let address = postalAddressStringFromAddressDictionary(self.addressDictionary as Dictionary<NSObject, AnyObject>?, addCountryName: false)
        let postalAddress = PostalAddress(address: address, city: self.locality, zipCode: self.postalCode,
                                          state: self.administrativeArea, countryCode: self.isoCountryCode, country: self.country)

        place.postalAddress = postalAddress

        var resumedData = ""
        if let name = self.name {
            resumedData += name
            // if the user searches for the city, then the city will appear twice in the resumedData string
            if let city = self.locality, city != name {
                resumedData += ", \(city)"
            }
        }
        if let state = self.administrativeArea {
            resumedData += ", \(state)"
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
    private func postalAddressStringFromAddressDictionary(_ addressDict: Dictionary<AnyHashable,Any>?,
        addCountryName: Bool) -> String? {
            guard let addressDict = addressDict else { return nil }
            let addressString: String
            if #available(iOS 9.0, *) {
                let address = CNMutablePostalAddress()
                address.street = addressDict[CNPostalAddressStreetKey] as? String ?? ""
                address.state = addressDict[CNPostalAddressStateKey] as? String ?? ""
                address.postalCode = addressDict["ZIP"] as? String ?? ""
                address.city = addressDict[CNPostalAddressCityKey] as? String ?? ""
                address.isoCountryCode = addressDict[CNPostalAddressISOCountryCodeKey] as? String ?? ""
                if addCountryName {
                    address.country = addressDict[CNPostalAddressCountryKey] as? String ?? ""
                }
                addressString = CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
            } else {
                addressString = ABCreateStringWithAddressDictionary(addressDict, addCountryName)
            }
            return addressString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

