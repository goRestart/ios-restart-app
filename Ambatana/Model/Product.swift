//
//  Product.swift
//  Ambatana
//
//  Created by AHL on 16/3/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation

@objc protocol Product {
    
    // Parse common
    var objectId: String! { get }
    var updatedAt: NSDate! { get }
    var createdAt: NSDate! { get }
    
    var address: String? { get set }
    var category: NSNumber? { get set }
    var categoryId: NSNumber? { get set }
    var city: String? { get set }
    var countryCode: String? { get set }
    var currency: String? { get set }
    var descr: String? { get set }
    var gpsCoordinates: CLLocationCoordinate2D { get set }
    var hasImage0: Bool { get }
    var hasImage1: Bool { get }
    var hasImage2: Bool { get }
    var hasImage3: Bool { get }
    var hasImage4: Bool { get }
    var hasImage5: Bool { get }
    var languageCode: String? { get set }
    var name: String? { get set }
    var nameDirify: String? { get set }
    var price: NSNumber? { get set }
    var isThumbnailProcessed: NSNumber? { get set }
    var status: NSNumber? { get set }
    var type: NSNumber? { get set }
    var userId: NSNumber? { get set }
    var zipCode: String? { get set }
    
    func retrieveImage0AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage1AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage2AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage3AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage4AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
    func retrieveImage5AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void)
}


class PFProduct: PFObject, PFSubclassing, Product {

    enum FieldKey: String {
        case Address = "address", Category = "category", CategoryId = "category_id", City = "city", CountryCode = "country_code", Currency = "currency", Description = "description", GPSCoordinates = "gpscoords", Image0 =  "image_0", Image1 = "image_1", Image2 = "image_2", Image3 = "image_3", Image4 = "image_4", Image5 = "image_5", LanguageCode = "language_code", Name = "name", NameDirify = "name_dirify", Price = "price", IsThumbnailProcessed = "processed", Status = "status", ProductType = "type", User = "user", UserId = "user_id", ZipCode = "zip_code", CreatedAt = "createdAt", UpdatedAt = "updatedAt"
    }
    
    // MARK: - Class
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    // MARK: - PFSubclassing
    
    class func parseClassName() -> String! {
        return "Products"
    }
    
    // MARK: - Product
    
    var address: String? {
        get {
            return self[FieldKey.Address.rawValue] as? String
        }
        set {
            self[FieldKey.Address.rawValue] = newValue
        }
    }
    var category: NSNumber? {
        get {
            return self[FieldKey.Category.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.Category.rawValue] = newValue
        }
    }
    
    var categoryId: NSNumber? {
        get {
            return self[FieldKey.CategoryId.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.CategoryId.rawValue] = newValue
        }
    }
    var city: String? {
        get {
            return self[FieldKey.City.rawValue] as? String
        }
        set {
            self[FieldKey.City.rawValue] = newValue
        }
    }
    var countryCode: String? {
        get {
            return self[FieldKey.CountryCode.rawValue] as? String
        }
        set {
            self[FieldKey.CountryCode.rawValue] = newValue
        }
    }
    var currency: String? {
        get {
            return self[FieldKey.Currency.rawValue] as? String
        }
        set {
            self[FieldKey.Currency.rawValue] = newValue
        }
    }
    var descr: String? {
        get {
            return self[FieldKey.Description.rawValue] as? String
        }
        set {
            self[FieldKey.Description.rawValue] = newValue
        }
    }
    var gpsCoordinates: CLLocationCoordinate2D {
        get {
            if let geoPoint = self[FieldKey.GPSCoordinates.rawValue] as? PFGeoPoint {
                return CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        set {
            self[FieldKey.GPSCoordinates.rawValue] = PFGeoPoint(latitude: newValue.latitude, longitude: newValue.longitude)
        }
    }
    var hasImage0: Bool {
        get {
            return self[FieldKey.Image0.rawValue] != nil
        }
    }
    var hasImage1: Bool  {
        get {
            return self[FieldKey.Image1.rawValue] != nil
        }
    }
    var hasImage2: Bool  {
        get {
            return self[FieldKey.Image2.rawValue] != nil
        }
    }
    var hasImage3: Bool  {
        get {
            return self[FieldKey.Image3.rawValue] != nil
        }
    }
    var hasImage4: Bool  {
        get {
            return self[FieldKey.Image4.rawValue] != nil
        }
    }
    var hasImage5: Bool  {
        get {
            return self[FieldKey.Image5.rawValue] != nil
        }
    }
    
    var languageCode: String? {
        get {
            return self[FieldKey.LanguageCode.rawValue] as? String
        }
        set {
            self[FieldKey.LanguageCode.rawValue] = newValue
        }
    }
    var name: String? {
        get {
            return self[FieldKey.Name.rawValue] as? String
        }
        set {
            self[FieldKey.Name.rawValue] = newValue
        }
    }
    var nameDirify: String? {
        get {
            return self[FieldKey.NameDirify.rawValue] as? String
        }
        set {
            self[FieldKey.NameDirify.rawValue] = newValue
        }
    }
    var price: NSNumber? {
        get {
            return self[FieldKey.Price.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.Price.rawValue] = newValue
        }
    }
    var isThumbnailProcessed: NSNumber? {
        get {
            return self[FieldKey.IsThumbnailProcessed.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.IsThumbnailProcessed.rawValue] = newValue
        }
    }
    var status: NSNumber? {
        get {
            return self[FieldKey.Status.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.Status.rawValue] = newValue
        }
    }
    var type: NSNumber? {
        get {
            return self[FieldKey.ProductType.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.ProductType.rawValue] = newValue
        }
    }
    var userId: NSNumber? {
        get {
            return self[FieldKey.UserId.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.UserId.rawValue] = newValue
        }
    }
    var zipCode: String? {
        get {
            return self[FieldKey.ZipCode.rawValue] as? String
        }
        set {
            self[FieldKey.ZipCode.rawValue] = newValue
        }
    }
    
    func retrieveImage0AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void) {
        if hasImage0 {
            let imageFile = self[FieldKey.Image0.rawValue] as PFFile
            imageAsThumb(asThumb, imageFile: imageFile, completion: completion)
        }
    }
    
    func retrieveImage1AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void) {
        if hasImage1 {
            let imageFile = self[FieldKey.Image1.rawValue] as PFFile
            imageAsThumb(asThumb, imageFile: imageFile, completion: completion)
        }
    }
    
    func retrieveImage2AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void) {
        if hasImage2 {
            let imageFile = self[FieldKey.Image2.rawValue] as PFFile
            imageAsThumb(asThumb, imageFile: imageFile, completion: completion)
        }
    }
    
    func retrieveImage3AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void) {
        if hasImage3 {
            let imageFile = self[FieldKey.Image3.rawValue] as PFFile
            imageAsThumb(asThumb, imageFile: imageFile, completion: completion)
        }
    }
    
    func retrieveImage4AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void) {
        if hasImage4 {
            let imageFile = self[FieldKey.Image4.rawValue] as PFFile
            imageAsThumb(asThumb, imageFile: imageFile, completion: completion)
        }
    }
    
    func retrieveImage5AsThumb(asThumb: Bool, completion: (image: UIImage!, error: NSError!) -> Void) {
        if hasImage5 {
            let imageFile = self[FieldKey.Image0.rawValue] as PFFile
            imageAsThumb(asThumb, imageFile: imageFile, completion: completion)
        }
    }
    
    // MARK: - Private methods
    
    private func imageAsThumb(asThumb: Bool, imageFile: PFFile, completion: (image: UIImage!, error: NSError!) -> Void) {
        var shouldUseThumbs: Bool = false
        if asThumb {
            if let isThumbProcessed = self.isThumbnailProcessed {
                shouldUseThumbs = isThumbProcessed.boolValue
            }
        }
        
        // Thumbnail (from Ambatana)
        if shouldUseThumbs {
            if let imageURL = imageFile.url {
                let thumbURL = NSURL(string: ImageManager.sharedInstance.calculateThumnbailImageURLForProductImage(objectId, imageURL: imageURL))

                SDWebImageManager.sharedManager().downloadImageWithURL(thumbURL, options: nil, progress: nil, completed: {
                    [weak self] (image, error, cacheType, finished, url) -> Void in
                    // If there's an error then try to download the image from Parse
                    if error != nil {
                        self?.imageAsThumb(false, imageFile: imageFile, completion: completion)
                    }
                    else {
                        completion(image: image, error: nil)
                    }
                })
            }
        }
        // Image (from Parse)
        else {
            imageFile.getDataInBackgroundWithBlock({
                [weak self] (data, error) -> Void in
                completion(image: UIImage(data: data), error: error)
            })
        }
    }
}
