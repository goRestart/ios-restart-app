//
//  MyUser.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 28/10/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public protocol MyUser: User, UserDefaultsDecodable {
    var email: String? { get }
    var location: LGLocation? { get }
    var authProvider: AuthenticationProvider { get }
    
    init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, email: String?, location: LGLocation?, authProvider: AuthenticationProvider)
}

public extension MyUser {       
    var coordinates: LGLocationCoordinates2D? {
        guard let coordinates = location?.coordinate else { return nil }
        return LGLocationCoordinates2D(coordinates: coordinates)
    }
    var isDummy: Bool {
        let dummyRange = (email ?? "").rangeOfString("usercontent")
        if let isDummyRange = dummyRange where isDummyRange.startIndex == (email ?? "").startIndex {
            return true
        }
        else {
            return false
        }
    }
    
    func myUserWithNewAuthProvider(newAuthProvider: AuthenticationProvider) -> Self {
        return Self.init(objectId: objectId, name: name, avatar: avatar, postalAddress: postalAddress,
            email: email, location: location, authProvider: newAuthProvider)
    }

    func myUserWithNewLocation(newLocation: LGLocation) -> Self {
        return Self.init(objectId: objectId, name: name, avatar: avatar, postalAddress: postalAddress,
            email: email, location: newLocation, authProvider: authProvider)
    }
}


// MARK: - UserDefaultsDecodable

struct MyUserUDKeys {
    static let objectId = "objectId"
    static let name = "name"
    static let email = "email"
    static let password = "password"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let locationType = "locationType"
    static let avatar = "avatar"
    static let address = "address"
    static let city = "city"
    static let zipCode = "zipCode"
    static let countryCode = "countryCode"
    static let country = "country"
    static let authProvider = "authProvider"
}

public extension MyUser {
    public static func decode(dictionary: [String: AnyObject]) -> Self? {
        let objectId = dictionary[MyUserUDKeys.objectId] as? String
        let name = dictionary[MyUserUDKeys.name] as? String
        var avatar: File? = nil
        if let avatarURL = dictionary[MyUserUDKeys.avatar] as? String {
            avatar = LGFile(id: nil, urlString: avatarURL)
        }
        let address = dictionary[MyUserUDKeys.address] as? String
        let city = dictionary[MyUserUDKeys.city] as? String
        let zipCode = dictionary[MyUserUDKeys.zipCode] as? String
        let countryCode = dictionary[MyUserUDKeys.countryCode] as? String
        let country = dictionary[MyUserUDKeys.country] as? String
        let postalAddress = PostalAddress(address: address, city: city, zipCode: zipCode, countryCode: countryCode, country: country)
        let email = dictionary[MyUserUDKeys.email] as? String
        var locationType: LGLocationType
        if let locationTypeRaw = dictionary[MyUserUDKeys.locationType] as? String {
            locationType = LGLocationType(rawValue: locationTypeRaw) ?? .LastSaved
        }
        else {
            locationType = .LastSaved
        }
        var location: LGLocation? = nil
        if let latitude = dictionary[MyUserUDKeys.latitude] as? Double, let longitude = dictionary[MyUserUDKeys.longitude] as? Double {
            let clLocation = CLLocation(latitude: latitude, longitude: longitude)
            location = LGLocation(location: clLocation, type: locationType)
        }
        var authProvider: AuthenticationProvider = .Unknown
        if let authProviderStr = dictionary[MyUserUDKeys.authProvider] as? String {
            authProvider = AuthenticationProvider(rawValue: authProviderStr) ?? .Unknown
        }
        
        return self.init(objectId: objectId, name: name, avatar: avatar, postalAddress: postalAddress,
            email: email, location: location, authProvider: authProvider)
    }
    
    public func encode() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        dictionary[MyUserUDKeys.objectId] = objectId
        dictionary[MyUserUDKeys.name] = name
        dictionary[MyUserUDKeys.avatar] = avatar?.fileURL?.URLString
        dictionary[MyUserUDKeys.address] = postalAddress.address
        dictionary[MyUserUDKeys.city] = postalAddress.city
        dictionary[MyUserUDKeys.zipCode] = postalAddress.zipCode
        dictionary[MyUserUDKeys.countryCode] = postalAddress.countryCode
        dictionary[MyUserUDKeys.country] = postalAddress.country
        dictionary[MyUserUDKeys.email] = email
        dictionary[MyUserUDKeys.locationType] = location?.type.rawValue
        dictionary[MyUserUDKeys.latitude] = location?.coordinate.latitude
        dictionary[MyUserUDKeys.longitude] = location?.coordinate.longitude
        dictionary[MyUserUDKeys.authProvider] = authProvider.rawValue
        return dictionary
    }
}
