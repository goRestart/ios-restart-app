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
        case Address = "address", Category = "category", CategoryId = "category_id", City = "city", CountryCode = "country_code", CurrencyCode = "currency", Description = "description", GPSCoordinates = "gpscoords", Image0 =  "image_0", Image1 = "image_1", Image2 = "image_2", Image3 = "image_3", Image4 = "image_4", Image5 = "image_5", LanguageCode = "language_code", Name = "name", Price = "price", Processed = "processed", Status = "status", ProductType = "type", User = "user", UserId = "user_id", ZipCode = "zip_code"
        case ObjectId = "objectId"
    }
    
    // MARK: - Class
    
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
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
            self[FieldKey.Name.rawValue] = newValue ?? NSNull()
        }
    }
    public var descr: String? {
        get {
            return self[FieldKey.Description.rawValue] as? String
        }
        set {
            self[FieldKey.Description.rawValue] = newValue ?? NSNull()
        }
    }
    public var price: NSNumber? {
        get {
            return self[FieldKey.Price.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.Price.rawValue] = newValue ?? NSNull()
        }
    }
    public var currency: Currency? {
        get {
            if let currencyCode = self[FieldKey.CurrencyCode.rawValue] as? String {
                return CurrencyHelper.sharedInstance.currencyWithCurrencyCode(currencyCode)
            }
            return nil
        }
        set {
            let currencyCode = newValue?.code ?? NSNull()
            self[FieldKey.CurrencyCode.rawValue] = currencyCode
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
                self[FieldKey.GPSCoordinates.rawValue] = NSNull()
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
            self[FieldKey.Address.rawValue] = newValue.address ?? NSNull()
            self[FieldKey.City.rawValue] = newValue.city ?? NSNull()
            self[FieldKey.ZipCode.rawValue] = newValue.zipCode ?? NSNull()
            self[FieldKey.CountryCode.rawValue] = newValue.countryCode ?? NSNull()
        }
    }
    
    public var languageCode: String? {
        get {
            return self[FieldKey.LanguageCode.rawValue] as? String
        }
        set {
            self[FieldKey.LanguageCode.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var categoryId: NSNumber? {
        get {
            return self[FieldKey.CategoryId.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.CategoryId.rawValue] = newValue ?? NSNull()
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
            self[FieldKey.Status.rawValue] = newValue.rawValue
        }
    }
    
    public var thumbnail: File? {
        get {
            if let image0File = self[FieldKey.Image0.rawValue] as? PFFile {
                return image0File
            }
            return nil
        }
        set {
            self[FieldKey.Image0.rawValue] = newValue as? PFFile ?? NSNull()
        }
    }
    public var thumbnailSize: LGSize? {
        get {
            return nil
        }
    }
    
    public var images: [File] {
        get {
            var imageFiles: [File] = []
            let fields = [FieldKey.Image0, FieldKey.Image1, FieldKey.Image2, FieldKey.Image3, FieldKey.Image4, FieldKey.Image5]
            for field in fields {
                if let imageFile = self[field.rawValue] as? PFFile {
                    imageFiles.append(imageFile)
                }
            }
            return imageFiles
        }
        set {
            let fields = [FieldKey.Image0, FieldKey.Image1, FieldKey.Image2, FieldKey.Image3, FieldKey.Image4, FieldKey.Image5]
            var i = 0
            // Set the new images
            while i < fields.count && i < newValue.count {
                self[fields[i].rawValue] = newValue[i] as? PFFile ?? NSNull()
                i++
            }
            // Delete the remaining ones
            while i < fields.count {
                self[fields[i].rawValue] = NSNull()
                i++
            }
        }
    }
    
    public var user: User? {
        get {
            return self[FieldKey.User.rawValue] as? PFUser
        }
        set {
            self[FieldKey.User.rawValue] = newValue as? PFUser ?? NSNull()
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
        
    public func formattedPrice() -> String {
        let actualCurrencyCode = currency?.code ?? LGCoreKitConstants.defaultCurrencyCode
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
    
    public func updateWithProduct(product: Product) {
        name = product.name
        descr = product.descr
        price = product.price
        currency = product.currency
        
        location = product.location
        postalAddress = product.postalAddress
        
        languageCode = product.languageCode
        
        categoryId = product.categoryId
        status = product.status
        
        thumbnail = product.thumbnail
        images = product.images
        
        user = product.user
        
        processed = product.processed
    }
    
    // MARK: - Public methods
    
    public static func productFromProduct(product: Product) -> PAProduct {
        var parseProduct = PAProduct()
        parseProduct.name = product.name
        parseProduct.descr = product.descr
        parseProduct.price = product.price
        parseProduct.currency = product.currency
        
        parseProduct.location = product.location
        parseProduct.postalAddress = product.postalAddress
        
        parseProduct.languageCode = product.languageCode
        
        parseProduct.categoryId = product.categoryId
        parseProduct.status = product.status
        
        parseProduct.thumbnail = product.thumbnail
        parseProduct.images = product.images
        
        parseProduct.user = product.user
        
        parseProduct.processed = product.processed
        return parseProduct
    }
}
