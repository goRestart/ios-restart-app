//
//  DeviceLocation.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

protocol DeviceLocation {
    var latitude: Double? { get }
    var longitude: Double? { get }
    var locationType: String? { get }
    var address: String? { get }
    var city: String? { get }
    var zipCode: String? { get }
    var state: String? { get }
    var countryCode: String? { get }
    var country : String? { get }
    
    init(latitude: Double?, longitude: Double?, locationType: String?, address: String?,
         city: String?, zipCode: String?, state: String?, countryCode: String?, country : String?)
}

extension DeviceLocation {
    
    init(location: LGLocation?) {
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        let address = location?.postalAddress?.address
        let city = location?.postalAddress?.city
        let zipCode = location?.postalAddress?.zipCode
        let state = location?.postalAddress?.state
        let countryCode = location?.postalAddress?.countryCode
        let country = location?.postalAddress?.country
        let locationType = location?.type != .manual ? location?.type.rawValue : nil
        self.init(latitude: latitude, longitude: longitude, locationType: locationType, address: address,
                  city: city, zipCode: zipCode, state: state, countryCode: countryCode, country: country)
    }
    
    var location: LGLocation? {
        guard let latitude = latitude, let longitude = longitude, let locationType = locationType,
            let type = LGLocationType(rawValue: locationType) else { return nil }
        return LGLocation(latitude: latitude, longitude: longitude, type: type, postalAddress: postalAddress)
    }
    
    var postalAddress: PostalAddress {
        return PostalAddress(address: address, city: city, zipCode: zipCode, state: state, countryCode: countryCode, country: country)
    }
}


// MARK: - UserDefaultsDecodable

struct DeviceLocationUDKeys {
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let locationType = "locationType"
    
    static let address = "address"
    static let city = "city"
    static let zipCode = "zipCode"
    static let state = "state"
    static let countryCode = "countryCode"
    static let country = "country"
}

extension DeviceLocation {
    static func decode(_ dictionary: [String: Any]) -> Self? {
        let latitude = dictionary[DeviceLocationUDKeys.latitude] as? Double
        let longitude = dictionary[DeviceLocationUDKeys.longitude] as? Double
        let locationType = dictionary[DeviceLocationUDKeys.locationType] as? String
        let address = dictionary[DeviceLocationUDKeys.address] as? String
        let city = dictionary[DeviceLocationUDKeys.city] as? String
        let zipCode = dictionary[DeviceLocationUDKeys.zipCode] as? String
        let state = dictionary[DeviceLocationUDKeys.state] as? String
        let countryCode = dictionary[DeviceLocationUDKeys.countryCode] as? String
        let country = dictionary[DeviceLocationUDKeys.country] as? String
        return self.init(latitude: latitude, longitude: longitude, locationType: locationType, address: address,
                         city: city, zipCode: zipCode, state: state, countryCode: countryCode, country: country)
    }
    
    func encode() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary[DeviceLocationUDKeys.latitude]  = latitude
        dictionary[DeviceLocationUDKeys.longitude] = longitude
        dictionary[DeviceLocationUDKeys.locationType] = locationType
        dictionary[DeviceLocationUDKeys.address] = address
        dictionary[DeviceLocationUDKeys.city] = city
        dictionary[DeviceLocationUDKeys.zipCode] = zipCode
        dictionary[DeviceLocationUDKeys.state] = state
        dictionary[DeviceLocationUDKeys.countryCode] = countryCode
        dictionary[DeviceLocationUDKeys.country] = country
        return dictionary
    }
}
