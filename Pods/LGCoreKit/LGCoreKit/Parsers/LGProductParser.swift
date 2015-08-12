//
//  LGProductParser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public class LGProductParser {
    
    // Constant
    // > JSON keys
    private static let objectIdJSONKey = "object_id"
    private static let createdAtJSONKey = "created_at"
    private static let updatedAtJSONKey = "updated_at"
    
    private static let nameJSONKey = "name"
    private static let descriptionJSONKey = "description"
    private static let priceJSONKey = "price"
    private static let currencyCodeJSONKey = "currency"
    
    private static let latitudeJSONKey = "latitude"
    private static let longitudeJSONKey = "longitude"
    private static let distanceJSONKey = "distance"
    private static let distanceTypeJSONKey = "distance_type"

    private static let countryCodeJSONKey = "country_code"
    private static let cityJSONKey = "city"
    private static let zipCodeJSONKey = "zip_code"
    private static let postalAddressJSONKey = "address"
    
    private static let languageCodeJSONKey = "language_code"
    
    private static let categoryIdJSONKey = "category_id"
    private static let statusJSONKey = "status"
    
    private static let thumbnailURLJSONKey = "full_img_url_thumb"
    private static let thumbnailSizeJSONKey = "image_dimensions"
    private static let widthJSONKey = "width"
    private static let heightJSONKey = "height"
    
    private static let imagesJSONKey = "product_images"
    
    private static let userJSONKey = "user"
   
//    {
//        "object_id": "a3wZuVtevr",
//        "category_id": "1",
//        "name": "Playstation 3",
//        "description": "Second-hand PS3 at a cheap rate.",
//        "price": "200",
//        "currency": "USD",
//        "created_at": "2015-03-26 12:24:12",
//        "status": "1",
//        "full_img_url_thumb": "http://devel.cdn.letgo.com/images/6d/54/e5/08/44420ee9aa55bc1007caab9979337634_thumb.jpg",
//        "latitude": 44.4466759,
//        "longitude": 20.6881891,
//        "distance_type": "KM",
//        "country_code": "ES",
//        "language_code": "en",
//        "city": "Barcelona",
//        "address": "Avinguda Portal de l'Àngel, 38, Barcelona, ES",
//        "zip_code": "08002"
//        "updated_at": "2015-05-28 14:52:48",
//        "distance": "7295.698610247437",
//        "product_images": [
//           "http://devel.cdn.letgo.com/images/a2/cd/50/fb/c3afb87a292e1a75a2cc448cae9e1539.jpg"
//        ],
//        "user": {
//            "object_id": "WHmGjAxX8L",
//            "public_username": "Valy F.",
//            "avatar": "http://files.parsetfss.com/abbc9384-9790-4bbb-9db2-1c3522889e96/tfss-bcc7eccf-7b18-4ed7-9b87-7c6d3925e39b-WHmGjAxX8L.jpg",
//            "zipcode": "08002",
//            "city": "Barcelona",
//            "country_code": "ES"
//        },
//        "image_dimensions": {
//           "width": 200,
//           "height": 150
//        }
//    }
    public static func productWithJSON(json: JSON, currencyHelper: CurrencyHelper) -> LGProduct {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let rfc3339DateFormatter = NSDateFormatter()    // when dates are coming like "2015-08-10T15:58:02Z"
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        rfc3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        rfc3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        let product = LGProduct()
        product.objectId = json[LGProductParser.objectIdJSONKey].string
        if let createdAtStr = json[LGProductParser.createdAtJSONKey].string {       // @ahl: !
            if let date = dateFormatter.dateFromString(createdAtStr) {
                product.createdAt = date
            }
            else if let date = rfc3339DateFormatter.dateFromString(createdAtStr) {
                product.createdAt = date
            }
        }
        
        if let updatedAtStr = json[LGProductParser.updatedAtJSONKey].string {       // @ahl: !
            if let date = dateFormatter.dateFromString(updatedAtStr) {
                product.updatedAt = date
            }
            else if let date = rfc3339DateFormatter.dateFromString(updatedAtStr) {
                product.updatedAt = date
            }
        }
        
        product.name = json[LGProductParser.nameJSONKey].string
        product.descr = json[LGProductParser.descriptionJSONKey].string
        
        if let price = json[LGProductParser.priceJSONKey].string {      // @ahl: !
            product.price = (price as NSString).doubleValue
        }
        else if let price = json[LGProductParser.priceJSONKey].double {
            product.price = price
        }
        
        let currencyCode = json[LGProductParser.currencyCodeJSONKey].string ?? LGCoreKitConstants.defaultCurrencyCode
        product.currency = currencyHelper.currencyWithCurrencyCode(currencyCode)
        
        if let latitude = json[LGProductParser.latitudeJSONKey].double, let longitude = json[LGProductParser.longitudeJSONKey].double {
            product.location = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
        }
        
        if let distanceStr = json[LGProductParser.distanceJSONKey].string {     // @ahl: !
            product.distance = (distanceStr as NSString).doubleValue
        }
        else if let distance = json[LGProductParser.distanceJSONKey].double {
            product.distance = distance
        }
        
        if let distanceTypeStr = json[LGProductParser.distanceTypeJSONKey].string {
            product.distanceType = DistanceType.fromString(distanceTypeStr)
        }
        
        let postalAddress = PostalAddress()
        postalAddress.countryCode = json[LGProductParser.countryCodeJSONKey].string
        postalAddress.city = json[LGProductParser.cityJSONKey].string
        postalAddress.zipCode = json[LGProductParser.zipCodeJSONKey].string
        postalAddress.address = json[LGProductParser.postalAddressJSONKey].string
        product.postalAddress = postalAddress

        product.languageCode = json[LGProductParser.languageCodeJSONKey].string
        
        if let categoryIdStr = json[LGProductParser.categoryIdJSONKey].string {     // @ahl: !
            product.categoryId = categoryIdStr.toInt()
        }
        else if let categoryId = json[LGProductParser.categoryIdJSONKey].int {
            product.categoryId = categoryId
        }
        
        if let statusStr = json[LGProductParser.statusJSONKey].string,              // @ahl: !
            let statusRaw = statusStr.toInt(),
            let status = ProductStatus(rawValue: statusRaw) {
                product.status = status
        }
        else if let statusRaw = json[LGProductParser.statusJSONKey].int, let status = ProductStatus(rawValue: statusRaw) {
            product.status = status
        }
        
        if let thumbnailURLStr = json[LGProductParser.thumbnailURLJSONKey].string, let thumbnailURL = NSURL(string: thumbnailURLStr) {
            product.thumbnail = LGFile(url: thumbnailURL)
        }
        if let width = json[LGProductParser.thumbnailSizeJSONKey][LGProductParser.widthJSONKey].int,
            let height = json[LGProductParser.thumbnailSizeJSONKey][LGProductParser.heightJSONKey].int {
                product.thumbnailSize = LGSize(width: Float(width), height: Float(height))
        }

        if let imageUrlJsons = json[LGProductParser.imagesJSONKey].array {
            var images: [File] = []
            for imageUrlJson in imageUrlJsons {
                if let imageUrlStr = imageUrlJson.string, let imageURL = NSURL(string: imageUrlStr) {
                    let image = LGFile(url: imageURL)
                    images.append(image)
                }
            }
            product.images = images
        }
 
        let userJSON = json[LGProductParser.userJSONKey]
        if userJSON.error == nil {
            product.user = LGProductUserParser.userWithJSON(userJSON)
        }
        
        return product
    }
}
