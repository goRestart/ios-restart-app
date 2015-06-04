//
//  PFUser+LetGo.swift
//  LGCoreKit
//
//  Created by AHL on 17/3/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

extension PFUser: User {
    
    enum FieldKey: String {
        case Address = "address", Avatar = "avatar", City = "city", CountryCode = "country_code", GPSCoordinates = "gpscoords", PublicUsername = "username_public", ZipCode = "zipcode"
    }
    
    // MARK: - User
    
    public var publicUsername :String? {
        get {
            return self[FieldKey.PublicUsername.rawValue] as? String
        }
        set {
            self[FieldKey.PublicUsername.rawValue] = newValue
        }
    }
    
    public var avatarURL: NSURL? {
        get {
            if let avatarFile = self[FieldKey.Avatar.rawValue] as? PFFile, let avatarURLStr = avatarFile.url {
                return NSURL(string: avatarURLStr)
            }
            return nil
        }
    }
    
    public var gpsCoordinates: LGLocationCoordinates2D? {
        get {
            if let geoPoint = self[FieldKey.GPSCoordinates.rawValue] as? PFGeoPoint {
                return LGLocationCoordinates2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            return nil
        }
        set {
            if let actualCoordinates = gpsCoordinates {
                self[FieldKey.GPSCoordinates.rawValue] = PFGeoPoint(latitude: actualCoordinates.latitude, longitude: actualCoordinates.longitude)
            }
            else {
                self[FieldKey.GPSCoordinates.rawValue] = nil
            }
        }
    }
    
    public var postalAddress: PostalAddress {
        get {
            let address = PostalAddress()
            address.address = self[FieldKey.Address.rawValue] as? String ?? ""
            address.city = self[FieldKey.City.rawValue] as? String ?? ""
            address.zipCode = self[FieldKey.ZipCode.rawValue] as? String ?? ""
            address.countryCode = self[FieldKey.CountryCode.rawValue] as? String ?? ""
            return address
        }
        set {
            self[FieldKey.Address.rawValue] = newValue.address
            self[FieldKey.City.rawValue] = newValue.city
            self[FieldKey.ZipCode.rawValue] = newValue.zipCode
            self[FieldKey.CountryCode.rawValue] = newValue.countryCode
        }
    }
}