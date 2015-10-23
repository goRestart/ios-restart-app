//
//  PFUser+User.swift
//  LGCoreKit
//
//  Created by AHL on 17/3/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import ParseFacebookUtilsV4

extension PFUser: User {
    
    enum FieldKey: String {
        case Address = "address", Avatar = "avatar", City = "city", CountryCode = "country_code", GPSCoordinates = "gpscoords", PublicUsername = "username_public", ZipCode = "zipcode", Processed = "processed", IsScammer = "is_scammer"
    }
    
    // MARK: - User
    
    public var publicUsername :String? {
        get {
            return self[FieldKey.PublicUsername.rawValue] as? String
        }
        set {
            self[FieldKey.PublicUsername.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var avatar: File? {
        get {
            return self[FieldKey.Avatar.rawValue] as? PFFile
        }
        set {
            if let file = newValue as? PFFile {
                self[FieldKey.Avatar.rawValue] = file
            }
            else {
                self[FieldKey.Avatar.rawValue] = NSNull()
            }
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
            if let actualCoordinates = newValue {
                self[FieldKey.GPSCoordinates.rawValue] = PFGeoPoint(latitude: actualCoordinates.latitude, longitude: actualCoordinates.longitude)
            }
            else {
                self[FieldKey.GPSCoordinates.rawValue] = NSNull()
            }
        }
    }
    
    public var postalAddress: PostalAddress {
        get {
            let address = PostalAddress()
            address.address = self[FieldKey.Address.rawValue] as? String
            address.city = self[FieldKey.City.rawValue] as? String
            address.zipCode = self[FieldKey.ZipCode.rawValue] as? String
            address.countryCode = self[FieldKey.CountryCode.rawValue] as? String
            return address
        }
        set {
            self[FieldKey.Address.rawValue] = newValue.address ?? NSNull()
            self[FieldKey.City.rawValue] = newValue.city ?? NSNull()
            self[FieldKey.ZipCode.rawValue] = newValue.zipCode ?? NSNull()
            self[FieldKey.CountryCode.rawValue] = newValue.countryCode ?? NSNull()

        }
    }
    
    public var processed: NSNumber? {
        get {
            return self[FieldKey.Processed.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.Processed.rawValue] = newValue ?? NSNull()
        }
    }
    
    
    public var isDummy: Bool {
        if let actualUsername = username {
            actualUsername.hasPrefix("usercontent")
        }
        return false
    }
    
    public var isAnonymous: Bool {
        // `YES` if the user is anonymous. `NO` if the user is not the current user or is not anonymous.
        return PFAnonymousUtils.isLinkedWithUser(self)
    }
    
    public var isScammer: NSNumber? {
        get {
            return self[FieldKey.IsScammer.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.IsScammer.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var didLogInByFacebook: Bool {
        return PFFacebookUtils.isLinkedWithUser(self)
    }
}