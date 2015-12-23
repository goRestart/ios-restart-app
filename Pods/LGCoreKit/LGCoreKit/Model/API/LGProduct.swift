//
//  LGPartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

public struct LGProduct: Product {
    
    // Global iVars
    public var objectId: String?
    public var updatedAt: NSDate?
    public var createdAt: NSDate?
    
    // Product iVars
    public var name: String?
    public var descr: String?
    public var price: Double?
    public var currency: Currency?
    
    public var location: LGLocationCoordinates2D
    public var postalAddress: PostalAddress
    
    public var languageCode: String?
    
    public var category: ProductCategory
    public var status: ProductStatus
    
    public var thumbnail: File?
    public var thumbnailSize: LGSize?
    public var images: [File]
    
    public var user: User
    
    init(objectId: String?, updatedAt: NSDate?, createdAt: NSDate?, name: String?, descr: String?, price: Double?,
        currency: String?, location: LGLocationCoordinates2D, postalAddress: PostalAddress, languageCode: String?,
        category: Int, status: Int, thumbnail: String?, thumbnailSize: LGSize?, images: [LGFile], user: LGUser){
            self.objectId = objectId
            self.updatedAt = updatedAt
            self.createdAt = createdAt
            self.name = name
            self.descr = descr
            self.price = price
            self.currency = Currency.currencyWithCode(currencyCode: currency)
            self.location = location
            self.postalAddress = postalAddress
            self.languageCode = languageCode
            self.category = ProductCategory(rawValue: category) ?? .Other
            self.status = ProductStatus(rawValue: status) ?? .Pending
            self.thumbnail = LGFile(id: nil, urlString: thumbnail)
            self.thumbnailSize = thumbnailSize
            self.images = images.map({$0})
            self.user = user
    }
}

// Designated initializers
extension LGProduct {
    public init() {
        self.images = []
        self.postalAddress = PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
        self.status = .Pending
        self.location = LGLocationCoordinates2D(latitude: 0, longitude: 0)
        self.category = ProductCategory.Other
        self.status = ProductStatus.Pending
        self.user = LGUser()
    }
    
    public init(product: Product) {
        self.objectId = product.objectId
        self.updatedAt = product.updatedAt
        self.createdAt = product.createdAt
        self.name = product.name
        self.descr = product.descr
        self.price = product.price
        self.currency = product.currency
        self.location = product.location
        self.postalAddress = product.postalAddress
        self.languageCode = product.languageCode
        self.category = product.category
        self.status = product.status
        self.thumbnail = product.thumbnail
        self.thumbnailSize = product.thumbnailSize
        self.images = product.images
        self.user = product.user
    }
}

//String convertible
extension LGProduct: CustomStringConvertible {
    public var description: String {
        
        return "name: \(name); descr: \(descr); price: \(price); currency: \(currency); location: \(location); postalAddress: \(postalAddress); languageCode: \(languageCode); category: \(category); status: \(status); thumbnail: \(thumbnail); thumbnailSize: \(thumbnailSize); images: \(images); user: \(user); descr: \(descr);"
    }
}

extension LGProduct : Decodable {
    /**
    Expects a json in the form:
    
        {
            "id": "283jcsBPuR",
            "name": "Ylg smartwatch",
            "category_id": 3,
            "language_code": "YES",
            "description": "Ylg smartwatch new",
            "price": 1,
            "currency": "YEUR",
            "status": 1,
            "geo": {
                "lat": 1,
                "lng": 1,
                "country_code": "YES",
                "city": "YVallés",
                "zip_code": "46818",
                "distance": 351.51723732342
            },
            "owner": {
                "id": "Jfp19JJRqb",
                "public_username": "Mark markrz",
                "avatar_url": "http://files.parsetfss.com/abbc9384-9790-4bbb-9db2-1c3522889e96/tfss-7b0e929c-f177-485b-8f31-d47c37f3bf77-Jfp19JJRqb.jpg",
                "is_richy": false
            },
            "images": [
                {
                    "url": "http://devel.cdn.letgo.com/images/56/82/91/fd/e3866f07983557cd8619433ff4fc3177.jpg",
                    "id": null
                }
            ],
            "thumb": {
                "url": "http://devel.cdn.letgo.com/images/56/82/91/fd/e3866f07983557cd8619433ff4fc3177_thumb.jpg",
                "width": 720,
                "height": 1280
            },
            "created_at": "2015-08-25T15:47:47+0000",
            "updated_at": "2015-08-25T15:47:47+0000",
        }
    */
    public static func decode(j: JSON) -> Decoded<LGProduct> {
        
        let init1 = curry(LGProduct.init)
                            <^> j <|? "id"                                          // objectId : String?
                            <*> LGArgo.parseDate(json: j, key: "updated_at")        // updatedAt : NSDate?
                            <*> LGArgo.parseDate(json: j, key: "created_at")        // createdAt : NSDate?
                            <*> j <|? "name"                                        // name : String?
                            <*> j <|? "description"                                 // descr : String?
        let init2 = init1   <*> j <|? "price"                                       // price : Float?
                            <*> j <|? "currency"                                    // currencty : String?
                            <*> LGArgo.jsonToCoordinates(j <| "geo", latKey: "lat", lonKey: "lng")   // location : LGLocationCoordinates2D?
                            <*> j <| "geo"                                          // postalAddress : PostalAddress
                            <*> j <|? "language_code"                               // languageCode : String?
                            <*> j <| "category_id"                                  // category_id : Int
                            <*> j <| "status"                                       // status : Int
        let result = init2  <*> j <|? ["thumb", "url"]                              // thumbnail : String?
                            <*> j <|? "thumb"                                       // thumbnailSize : LGSize?
                            <*> (j <||? "images" >>- LGArgo.jsonArrayToFileArray)   // images : [LGFile]
                            <*> j <| "owner"                                        // user : LGUser?
        
        if let error = result.error {
            print("LGProduct parse error: \(error)")
        }
        
        return result
    }
}