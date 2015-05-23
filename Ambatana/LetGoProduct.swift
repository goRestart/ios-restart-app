//
//  LetGoProduct.swift
//  LetGo
//
//  Created by Nacho on 13/4/15.
//  Copyright (c) 2015 LetGo. All rights reserved.
//

import UIKit
import CoreLocation

class LetGoProduct: NSObject, Printable {
    // global variables every object must have (retrieved in product list).
    var objectId: String!
    var category: LetGoProductCategory!
    var name: String!
    var price: Double!
    var currency: String!
    var creationDate: NSDate!
    var status: LetGoProductStatus!
    var thumbnailURL: String!
    var thumbnailImage: UIImage?
    var thumbnailSize: CGSize?
    var distanceType: LetGoDistanceMeasurementSystem?
    var distanceToUser: Double?
    
    // full product data, only retrieved if requested explicitly to the REST API
    var productDescription: String?
    var city: String?
    var countryCode: String?
    var nameDirify: String?
    var languageCode: String?
    var userId: String? // ID of the user that owns the object
    var location: CLLocationCoordinate2D?
    //var updatedAt: NSDate
    var imageURLs: [String]?
    var images: [UIImage] = []
    var thumbnailURLs: [String]?
    var thumbnails: [UIImage] = []
    
    
    // Lifecycle
    
    /** Designated initializer. Used to initialize the object by specifying all the variables */
    init(objectId: String, category: LetGoProductCategory, name: String, price: Double, currency: String, creationDate: NSDate, status: LetGoProductStatus, thumbnailURL: String, thumbnailSize: CGSize, distanceType: LetGoDistanceMeasurementSystem, distanceToUser: Double, loadThumbnailImage: Bool = true) {
        // assign variables
        self.objectId = objectId
        self.category = category
        self.name = name
        self.price = price
        self.currency = currency
        self.creationDate = creationDate
        self.status = status
        self.thumbnailURL = thumbnailURL
        self.thumbnailSize = thumbnailSize
        self.distanceType = distanceType
        self.distanceToUser = distanceToUser
        super.init()
        
    }
    
    /**
    * Initializer used to instanciate a product coming from the product list response of the API server.
    * Receives the data directly in the dictionary.
    */
    init?(valuesFromProductInListDictionary dictionary: [String: AnyObject], loadThumbnailImage: Bool = true) {
        super.init()
        
        // mandatory values
        
        // product ID
        if let objectId = dictionary[kLetGoRestAPIParameterObjectId] as? String {
            self.objectId = objectId
        } else { return nil }
        // product category
        let category: LetGoProductCategory?
        if let categoryNumber = dictionary[kLetGoRestAPIParameterCategoryId]?.integerValue {
            if let category = LetGoProductCategory(rawValue: categoryNumber) {
                self.category = category
            } else { return nil }
        } else { return nil }
        // product name
        if let name = dictionary[kLetGoRestAPIParameterName] as? String {
            self.name = name
        } else { return nil }
        // price
        if let price = dictionary[kLetGoRestAPIParameterPrice]?.doubleValue {
            self.price = price
        } else { return nil }
        // currency
        self.currency = dictionary[kLetGoRestAPIParameterCurrency] as? String
        // creation date
        if let createdAt = dictionary[kLetGoRestAPIParameterCreatedAt] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let firstDateAttempt = dateFormatter.dateFromString(createdAt) {
                self.creationDate = firstDateAttempt
            } else {
                dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm:ss"
                if let secondDateAttempt = dateFormatter.dateFromString(createdAt) {
                    self.creationDate = secondDateAttempt
                } else { self.creationDate = NSDate() }
            }
        } else { return nil }
        // status
        if let statusNumber = dictionary[kLetGoRestAPIParameterStatus]?.integerValue {
            if let status = LetGoProductStatus(rawValue: statusNumber) {
                self.status = status
            } else { return nil }
        } else { return nil }
        // thumbnail URL
        if let thumbnailURL = dictionary[kLetGoRestAPIParameterImgURLThumb] as? String {
            self.thumbnailURL = ImageManager.sharedInstance.fullImagePathForRelativePath(thumbnailURL)
        } else { // try to get image from image0
            if let image0URL = dictionary[kLetGoRestAPIParameterInitialThumb] as? String {
                self.thumbnailURL = ImageManager.sharedInstance.fullImagePathForRelativePath(image0URL)
            } else { return nil }
        }
        if loadThumbnailImage {
            ImageManager.sharedInstance.retrieveImageFromURLString(self.thumbnailURL, completion: { (success, image, fromURL) -> Void in
                if success && fromURL == self.thumbnailURL { self.thumbnailImage = image }
            })
        }
        
        // optional values
        
        // thumbnail size
        var width: CGFloat = 0.0; var height: CGFloat = 0.0
        if let thumbnailSize = dictionary[kLetGoRestAPIParameterImageDimensions] as? [String: AnyObject] {
            width = thumbnailSize[kLetGoRestAPIParameterWidth] as? CGFloat ?? CGFloat(0)
            height = thumbnailSize[kLetGoRestAPIParameterHeight] as? CGFloat ?? CGFloat(0)
            if width != 0.0 && height != 0.0 { self.thumbnailSize = CGSizeMake(width, height) }
        }
        // distance type
        var distanceType: LetGoDistanceMeasurementSystem?
        if let distanceString = dictionary[kLetGoRestAPIParameterDistanceType] as? String {
            if let distanceType = LetGoDistanceMeasurementSystem(distanceString: distanceString) {
                self.distanceType = distanceType
            }
        }
        // distance to user.
        if let distanceToUser = dictionary[kLetGoRestAPIParameterDistance]?.doubleValue {
            self.distanceToUser = distanceToUser
        }
    }
    
    /**
    * Initializer used to instanciate a product coming from the full product description of the product in the REST API.
    * Receives the data in two dictionaries:
    * - product: product information as dictionary, its mandatory part is equal to the one received in init(valuesFromProductInListDictionary...)
    * - images: contains an array with the images as dictionary { original, thumb } pairs
    */
    convenience init?(valuesFromFullProductDictionary dictionary: [String: AnyObject], loadImages: Bool = false) {
        if let productData = dictionary[kLetGoRestAPIParameterProduct] as? [String: AnyObject] {
            self.init(valuesFromProductInListDictionary: productData, loadThumbnailImage: false)
            // read optional values from "product"
            if let productDescription = productData[kLetGoRestAPIParameterProductDescription] as? String { self.productDescription = productDescription }
            if let city = productData[kLetGoRestAPIParameterCity] as? String { self.city = city }
            if let countryCode = productData[kLetGoRestAPIParameterCountryCode] as? String { self.countryCode = countryCode }
            if let nameDirify = productData[kLetGoRestAPIParameterNameDirify] as? String { self.nameDirify = nameDirify }
            if let languageCode = productData[kLetGoRestAPIParameterLanguageCode] as? String { self.languageCode = languageCode }
            if let userId = productData[kLetGoRestAPIParameterUserId] as? String { self.userId = userId }
            if let latitude = productData[kLetGoRestAPIParameterLatitude]?.floatValue {
                if let longitude = productData[kLetGoRestAPIParameterLongitude]?.floatValue {
                    let location = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
                    if CLLocationCoordinate2DIsValid(location) { self.location = location }
                }
            }
            
            // read images from "images"
            if let productImages = dictionary[kLetGoRestAPIParameterImages] as? [[String: AnyObject]] {
                thumbnailURLs = []
                imageURLs = []
                thumbnails = []
                images = []
                for productImage in productImages {
                    if let relativeThumbnailURL = productImage[kLetGoRestAPIParameterImageThumb] as? String {
                        let thumbnailURL = ImageManager.sharedInstance.fullImagePathForRelativePath(relativeThumbnailURL)
                        self.thumbnailURLs!.append(thumbnailURL)
                        // load thumbnail from URL
                        if loadImages {
                            ImageManager.sharedInstance.retrieveImageFromURLString(thumbnailURL, completion: { (success, image, fromURL) -> Void in
                                if success && fromURL == self.thumbnailURL { self.thumbnails.append(image!) }
                            })
                        }
                    }
                    if let relativeOriginalURL = productImage[kLetGoRestAPIParameterImageOriginal] as? String {
                        let originalURL = ImageManager.sharedInstance.fullImagePathForRelativePath(relativeOriginalURL)
                        self.imageURLs!.append(originalURL)
                        // load original image from URL
                        if loadImages {
                            ImageManager.sharedInstance.retrieveImageFromURLString(originalURL, completion: { (success, image, fromURL) -> Void in
                                if success && fromURL == self.thumbnailURL { self.images.append(image!) }
                            })
                        }
                    }
                }
            }
        } else { self.init(valuesFromProductInListDictionary: [:], loadThumbnailImage: false) } // returns nil
        
        
    }
    
    override var description: String {
        return "* LetGo Product [\(objectId)]. \n\tName: \(name), \n\tcategory: \(category.getName()), \n\tprice: \(price), \n\tcurrency: \(currency), \n\tcreationDate: \(creationDate), \n\tstatus: \(status.rawValue), \n\tthumbnailURL: \(thumbnailURL), \n\tthumbnailSize: \(thumbnailSize), \n\tdistanceType: \(distanceType?.distanceMeasurementStringForRestAPI()), \n\tdistanceToUser: \(distanceToUser)\n- Optional Values: \n\tdescription: \(productDescription)\n\tcity: \(city),\n\tcountryCode: \(countryCode),\n\tnameDirify: \(nameDirify),\n\tlanguageCode: \(languageCode),\n\tuserID: \(userId),\n\tlocation: \(location)\n\timageURLs: \(imageURLs)\n\tthumbnailURLs: \(thumbnailURLs)\n\n"
    }
    
    // MARK: - Equality and searching.
    override var hashValue: Int {
        return objectId.hash
    }
    
}

func == (lhs: LetGoProduct, rhs: LetGoProduct) -> Bool {
    return (lhs.objectId == rhs.objectId)
}













