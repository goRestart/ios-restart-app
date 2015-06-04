//
//  PAProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Parse

@objc public class PAProduct: PFObject, PFSubclassing, Product {

    // Constants & Enums
    
    internal enum FieldKey: String {
        case Address = "address", Category = "category", CategoryId = "category_id", City = "city", CountryCode = "country_code", Currency = "currency", Description = "description", GPSCoordinates = "gpscoords", Image0 =  "image_0", Image1 = "image_1", Image2 = "image_2", Image3 = "image_3", Image4 = "image_4", Image5 = "image_5", LanguageCode = "language_code", Name = "name", Price = "price", IsThumbnailProcessed = "processed", Status = "status", ProductType = "type", User = "user", UserId = "user_id", ZipCode = "zip_code"
        case ObjectId = "objectId"
    }
    
    // MARK: - Class
    
    override public class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    // MARK: - PFSubclassing
    
    public class func parseClassName() -> String {
        return "Products"
    }
    
    // MARK: - Product
    
    public var name: String? {
        get {
            return self[FieldKey.Name.rawValue] as? String
        }
        set {
            self[FieldKey.Name.rawValue] = newValue ?? ""
        }
    }
    public var descr: String? {
        get {
            return self[FieldKey.Description.rawValue] as? String
        }
        set {
            self[FieldKey.Description.rawValue] = newValue ?? ""
        }
    }
    public var price: NSNumber? {
        get {
            return self[FieldKey.Address.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.Price.rawValue] = newValue ?? ""
        }
    }
    public var currencyCode: String? {
        get {
            return self[FieldKey.CountryCode.rawValue] as? String
        }
        set {
            self[FieldKey.CountryCode.rawValue] = newValue ?? ""
        }
    }
    
    public var location: LGLocationCoordinates2D? {
        get {
            if let geoPoint = self[FieldKey.GPSCoordinates.rawValue] as? PFGeoPoint {
                return LGLocationCoordinates2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            return nil
        }
        set {
            if let actualNewValue = newValue {
                self[FieldKey.GPSCoordinates.rawValue] = PFGeoPoint(latitude: actualNewValue.latitude, longitude: actualNewValue.longitude)
            }
            else {
                self[FieldKey.GPSCoordinates.rawValue] = nil
            }
        }
    }
    public var distance: NSNumber? {
        get {
            if let productLocation = location, let user = MyUserManager.sharedInstance.myUser(), let userCoordinates = user.gpsCoordinates {
                let productLoc = CLLocation(latitude: productLocation.latitude, longitude: productLocation.longitude)
                let userLoc = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
                let distanceMeters = Float(userLoc.distanceFromLocation(productLoc))
                let dt = distanceType ?? .Km
                switch dt {
                case .Mi:
                    return NSNumber(float: distanceMeters * 0.000621)
                case .Km:
                    return NSNumber(float: distanceMeters / 1000)
                }
            }
            return nil
        }
    }
    public var distanceType: DistanceType {
        get {
            if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
                return usesMetric ? .Km : .Mi
            }
            else {
                return .Km
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
            self[FieldKey.Address.rawValue] = newValue.address ?? ""
            self[FieldKey.City.rawValue] = newValue.city ?? ""
            self[FieldKey.ZipCode.rawValue] = newValue.zipCode ?? ""
            self[FieldKey.CountryCode.rawValue] = newValue.countryCode ?? ""
        }
    }
    
    public var languageCode: String? {
        get {
            return self[FieldKey.LanguageCode.rawValue] as? String
        }
        set {
            self[FieldKey.LanguageCode.rawValue] = newValue ?? ""
        }
    }
    
    public var categoryId: NSNumber? {
        get {
            return self[FieldKey.CategoryId.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.CategoryId.rawValue] = newValue ?? 8  // other
        }
    }
    
    public var status: ProductStatus {
        get {
            if let productStatusCode = self[FieldKey.Status.rawValue] as? Int, let productStatus = ProductStatus(rawValue: productStatusCode) {
                return productStatus
            }
            return ProductStatus.Pending
        }
        set {
            self[FieldKey.Address.rawValue] = newValue.rawValue
        }
    }
    
    public var thumbnailURL: NSURL? {
        get {
            if let image0File = self[FieldKey.Image0.rawValue] as? PFFile, let image0UrlStr = image0File.url {
                return NSURL(string: image0UrlStr)
            }
            return nil
        }
    }
    public var thumbnailSize: LGSize? {
        get {
            return nil
        }
    }
    
    public var imageURLs: [NSURL] {
        get {
            var urls: [NSURL] = []
            let fields = [FieldKey.Image0, FieldKey.Image1, FieldKey.Image2, FieldKey.Image3, FieldKey.Image4, FieldKey.Image5]
            for field in fields {
                if let imageFile = self[field.rawValue] as? PFFile, let imageUrlStr = imageFile.url, imageURL = NSURL(string: imageUrlStr) {
                    urls.append(imageURL)
                }
            }
            return urls
        }
    }
    
    public var user: User? {
        get {
            return self[FieldKey.User.rawValue] as? PFUser
        }
    }
        
    public func formattedPrice() -> String {
        let actualCurrencyCode = currencyCode ?? LGCoreKitConstants.defaultCurrencyCode
        if let actualPrice = price {
            let formattedPrice = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(actualCurrencyCode, amount: actualPrice)
            return formattedPrice ?? "\(actualPrice)"
        }
        else {
            return ""
        }
    }
    
    public func formattedDistance() -> String {
        if let actualDistance = distance {
            let actualDistanceType = distanceType ?? LGCoreKitConstants.defaultDistanceType
            return actualDistanceType.formatDistance(actualDistance.floatValue)
        }
        else {
            return ""
        }
    }
}
