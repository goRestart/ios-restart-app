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
    private static let idJSONKey = "id"
    private static let createdAtJSONKey = "created_at"
    private static let updatedAtJSONKey = "updated_at"
    
    private static let nameJSONKey = "name"
    private static let descriptionJSONKey = "description"
    
    private static let priceJSONKey = "price"
    private static let currencyCodeJSONKey = "currency"

    private static let geoJSONKey = "geo"
    private static let latJSONKey = "lat"
    private static let lngJSONKey = "lng"
    private static let countryCodeJSONKey = "country_code"
    private static let cityJSONKey = "city"
    private static let zipCodeJSONKey = "zip_code"
    private static let distanceJSONKey = "distance"
    
    private static let languageCodeJSONKey = "language_code"
    private static let categoryIdJSONKey = "category_id"
    private static let statusJSONKey = "status"
    
    private static let thumbJSONKey = "thumb"
    private static let thumbUrlJSONKey = "url"
    private static let thumbWidthJSONKey = "width"
    private static let thumbHeightJSONKey = "height"
    
    private static let imagesArrayJSONKey = "images"
    private static let imageUrlJSONKey = "url"
    private static let imageTokenJSONKey = "id"
    
    private static let ownerJSONKey = "owner"

//    {
//        "id": "283jcsBPuR",
//        "name": "Ylg smartwatch",
//        "category_id": 3,
//        "language_code": "YES",
//        "description": "Ylg smartwatch new",
//        "price": 1,
//        "currency": "YEUR",
//        "status": 1,
//        "geo": {
//            "lat": 1,
//            "lng": 1,
//            "country_code": "YES",
//            "city": "YVallés",
//            "zip_code": "46818",
//            "distance": 351.51723732342
//        },
//        "owner": {
//            "id": "Jfp19JJRqb",
//            "public_username": "Mark markrz",
//            "avatar_url": "http://files.parsetfss.com/abbc9384-9790-4bbb-9db2-1c3522889e96/tfss-7b0e929c-f177-485b-8f31-d47c37f3bf77-Jfp19JJRqb.jpg",
//            "is_richy": false
//        },
//        "images": [
//            {
//                "url": "http://devel.cdn.letgo.com/images/56/82/91/fd/e3866f07983557cd8619433ff4fc3177.jpg",
//                "id": null
//            }
//        ],
//        "thumb": {
//            "url": "http://devel.cdn.letgo.com/images/56/82/91/fd/e3866f07983557cd8619433ff4fc3177_thumb.jpg",
//            "width": 720,
//            "height": 1280
//        },
//        "created_at": "2015-08-25T15:47:47+0000",
//        "updated_at": "2015-08-25T15:47:47+0000",
//    }
    public static func productWithJSON(json: JSON, currencyHelper: CurrencyHelper, distanceType: DistanceType) -> LGProduct {
        let product = LGProduct()
        product.objectId = json[LGProductParser.idJSONKey].string
        
        if let createdAtStr = json[LGProductParser.createdAtJSONKey].string, let date = LGDateFormatter.sharedInstance.dateFromString(createdAtStr) {
            product.createdAt = date
        }
        if let updatedAtStr = json[LGProductParser.updatedAtJSONKey].string, let date = LGDateFormatter.sharedInstance.dateFromString(updatedAtStr) {
            product.updatedAt = date
        }
        
        product.name = json[LGProductParser.nameJSONKey].string
        product.descr = json[LGProductParser.descriptionJSONKey].string
        
        if let price = json[LGProductParser.priceJSONKey].double {
            product.price = price
        }
        
        let currencyCode = json[LGProductParser.currencyCodeJSONKey].string ?? LGCoreKitConstants.defaultCurrencyCode
        product.currency = currencyHelper.currencyWithCurrencyCode(currencyCode)
        
        if let geo = json[LGProductParser.geoJSONKey].dictionary {
            
            if let latitude = geo[LGProductParser.latJSONKey]?.double, let longitude = geo[LGProductParser.lngJSONKey]?.double {
                product.location = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
            }
            
            if let distanceStr = geo[LGProductParser.distanceJSONKey]?.string {
                product.distance = (distanceStr as NSString).doubleValue
            }
            else if let distance = geo[LGProductParser.distanceJSONKey]?.double {
                product.distance = distance
            }

            product.distanceType = distanceType
            
            let postalAddress = PostalAddress()
            
            if let countryCode = geo[LGProductParser.countryCodeJSONKey]?.string {
                postalAddress.countryCode = countryCode
            }
            if let city = geo[LGProductParser.cityJSONKey]?.string {
                postalAddress.city = city
            }
            if let zipCode = geo[LGProductParser.zipCodeJSONKey]?.string {
                postalAddress.zipCode = zipCode
            }
            postalAddress.address = nil
            product.postalAddress = postalAddress
        }
        
        product.languageCode = json[LGProductParser.languageCodeJSONKey].string
        
        if let categoryId = json[LGProductParser.categoryIdJSONKey].int {
            product.categoryId = categoryId
        }
        
        if let statusRaw = json[LGProductParser.statusJSONKey].int, let status = ProductStatus(rawValue: statusRaw) {
            product.status = status
        }
        
        if let thumbnail = json[LGProductParser.thumbJSONKey][LGProductParser.thumbUrlJSONKey].string, let thumbnailURL = NSURL(string: thumbnail) {
            product.thumbnail = LGFile(url: thumbnailURL)
        }
        
        if let width = json[LGProductParser.thumbJSONKey][LGProductParser.thumbWidthJSONKey].float,
           let height = json[LGProductParser.thumbJSONKey][LGProductParser.thumbHeightJSONKey].float {
                product.thumbnailSize = LGSize(width: width, height: height)
        }

        if let imageUrlJsons = json[LGProductParser.imagesArrayJSONKey].array {
            var images: [File] = []
            for imageJsonDict in imageUrlJsons {
                if let imageUrlString = imageJsonDict[LGProductParser.imageUrlJSONKey].string, let imageURL = NSURL(string: imageUrlString) {
                    let imageFile = LGFile(url: imageURL)
                    if let imageToken = imageJsonDict[LGProductParser.imageTokenJSONKey].string {
                        imageFile.token = imageToken
                    }
                    
                    images.append(imageFile)
                }
            }
            product.images = images
        }
        
        if json[LGProductParser.ownerJSONKey] != nil {
            product.user = LGProductUserParser.userWithJSON(json[LGProductParser.ownerJSONKey])
        }

        return product
    }
}
