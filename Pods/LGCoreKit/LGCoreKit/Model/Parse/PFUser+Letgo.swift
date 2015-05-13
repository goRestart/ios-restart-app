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
        case Address = "address", Avatar = "avatar", City = "city", CountryCode = "country_code", GPSCoordinates = "gpscoords", /*Radius = "radius",*/ PublicUsername = "username_public", ZipCode = "zipcode"
        case ObjectId = "objectId", CreatedAt = "createdAt", UpdatedAt = "updatedAt"
    }
    
    // MARK: - User
   
    public var address: String? {
        get {
            return self[FieldKey.Address.rawValue] as? String
        }
        set {
            self[FieldKey.Address.rawValue] = newValue
        }
    }
    public var avatarURL: String? {
        get {
            if let avatar = self[FieldKey.Avatar.rawValue] as? PFFile {
                return avatar.url
            }
            return nil
        }
    }
        
    public var city: String? {
        get {
            return self[FieldKey.City.rawValue] as? String
        }
        set {
            self[FieldKey.City.rawValue] = newValue
        }
    }
    public var countryCode: String? {
        get {
            return self[FieldKey.CountryCode.rawValue] as? String
        }
        set {
            self[FieldKey.CountryCode.rawValue] = newValue
        }
    }
    public var gpsCoordinates: CLLocationCoordinate2D {
        get {
            if let geoPoint = self[FieldKey.GPSCoordinates.rawValue] as? PFGeoPoint {
                return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            return kCLLocationCoordinate2DInvalid
        }
        set {
            self[FieldKey.GPSCoordinates.rawValue] = PFGeoPoint(latitude: newValue.latitude, longitude: newValue.longitude)
        }
    }
//    public var radius: NSNumber? {
//        get {
//            return self[FieldKey.Radius.rawValue] as? NSNumber
//        }
//        set {
//            self[FieldKey.Radius.rawValue] = newValue
//        }
//    }
    public var publicUsername :String? {
        get {
            return self[FieldKey.PublicUsername.rawValue] as? String
        }
        set {
            self[FieldKey.PublicUsername.rawValue] = newValue
        }
    }
    public var zipCode: String? {
        get {
            return self[FieldKey.ZipCode.rawValue] as? String
        }
        set {
            self[FieldKey.ZipCode.rawValue] = newValue
        }
    }
}