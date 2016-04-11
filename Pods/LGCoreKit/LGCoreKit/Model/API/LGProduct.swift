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

    public var nameAutoEnglish: String?

    public var user: User
    
    // This parameters is not included in the API, we set a default value that must be changed if needed once 
    // the object is created after the decoding.
    public var favorite: Bool = false

    init(objectId: String?, updatedAt: NSDate?, createdAt: NSDate?, name: String?, descr: String?, price: Double?,
        currency: String?, location: LGLocationCoordinates2D, postalAddress: PostalAddress, languageCode: String?,
        category: Int, status: Int, thumbnail: String?, thumbnailSize: LGSize?, images: [LGFile],
        nameAutoEnglish: String?, user: LGUser) {
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
            self.nameAutoEnglish = nameAutoEnglish
            self.user = user
            self.favorite = false
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
        self.nameAutoEnglish = product.nameAutoEnglish
        self.user = product.user
        self.favorite = product.favorite
    }
}

//String convertible
extension LGProduct: CustomStringConvertible {
    public var description: String {

        return "name: \(name); descr: \(descr); price: \(price); currency: \(currency); location: \(location); postalAddress: \(postalAddress); languageCode: \(languageCode); category: \(category); status: \(status); thumbnail: \(thumbnail); thumbnailSize: \(thumbnailSize); images: \(images); nameAutoEnglish: \(nameAutoEnglish); user: \(user); descr: \(descr);"
    }
}

extension LGProduct : Decodable {
    /**
    Expects a json in the form:

        {
			"id": "0af7ebed-f285-4e84-8630-d1555ddbf102",
			"name": "",
			"category_id": 1,
			"language_code": "US",
			"description": "Selling a brand new, never opened FitBit, I'm asking for $75 negotiable.",
			"price": 75,
			"currency": "USD",
			"status": 1,
			"geo": {
				"lat": 40.733637875435,
				"lng": -73.982275536568,
				"country_code": "US",
				"city": "New York",
				"zip_code": "10003",
				"distance": 11.90776294472
			},
			"owner": {
				"id": "56da24a0-88d4-4956-a568-74739787051f",
				"name": "GeralD1507",
				"avatar_url": null,
				"zip_code": "10003",
				"country_code": "US",
				"is_richy": false,
				"city": "New York",
				"banned": null
			},
			"images": [{
				"url": "http:\/\/cdn.letgo.com\/images\/59\/1d\/f8\/22\/591df822060703afad9834d095ed4c2f.jpg",
				"id": "8ecdfe97-a7ed-4068-b4b8-c68a5ae63540"
			}],
			"thumb": {
				"url": "http:\/\/cdn.letgo.com\/images\/59\/1d\/f8\/22\/591df822060703afad9834d095ed4c2f_thumb.jpg",
				"width": 576,
				"height": 1024
			},
			"created_at": "2016-04-11T12:49:52+00:00",
			"updated_at": "2016-04-11T13:13:23+00:00",
			"image_information": "black fitbit wireless activity wristband"
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
                            <*> j <|? "image_information"                           // nameAutoEnglish : String?
                            <*> j <| "owner"                                        // user : LGUser?

        if let error = result.error {
            print("LGProduct parse error: \(error)")
        }

        return result
    }
}
