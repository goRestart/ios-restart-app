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
    public var nameAuto: String?
    public var descr: String?
    public var price: Double?
    public var currency: Currency

    public var location: LGLocationCoordinates2D
    public var postalAddress: PostalAddress

    public var languageCode: String?

    public var category: ProductCategory
    public var status: ProductStatus

    public var thumbnail: File?
    public var thumbnailSize: LGSize?
    public var images: [File]

    public var user: User
    
    // This parameters is not included in the API, we set a default value that must be changed if needed once 
    // the object is created after the decoding.
    public var favorite: Bool = false

    public init(objectId: String?, updatedAt: NSDate?, createdAt: NSDate?, name: String?, nameAuto: String?, descr: String?,
         price: Double?, currency: Currency, location: LGLocationCoordinates2D, postalAddress: PostalAddress,
         languageCode: String?, category: ProductCategory, status: ProductStatus, thumbnail: File?,
         thumbnailSize: LGSize?, images: [File], user: User) {
        self.objectId = objectId
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.name = name
        self.nameAuto = nameAuto
        self.descr = descr
        self.price = price
        self.currency = currency
        self.location = location
        self.postalAddress = postalAddress
        self.languageCode = languageCode
        self.category = category
        self.status = status
        self.thumbnail = thumbnail
        self.thumbnailSize = thumbnailSize
        self.images = images
        self.user = user
        self.favorite = false
    }

    static func productWithId(objectId: String?, updatedAt: NSDate?, createdAt: NSDate?, name: String?, nameAuto: String?, descr: String?,
         price: Double?, currency: String, location: LGLocationCoordinates2D, postalAddress: PostalAddress,
         languageCode: String?, category: Int, status: Int, thumbnail: String?, thumbnailSize: LGSize?,
         images: [LGFile], user: LGUser) -> LGProduct {
        let actualCurrency = Currency.currencyWithCode(currency)
        let actualCategory = ProductCategory(rawValue: category) ?? .Other
        let actualStatus = ProductStatus(rawValue: status) ?? .Pending
        let actualThumbnail = LGFile(id: nil, urlString: thumbnail)
        let actualImages = images.flatMap { $0 as File }

        return self.init(objectId: objectId, updatedAt: updatedAt, createdAt: createdAt, name: name,
                         nameAuto: nameAuto, descr: descr, price: price, currency: actualCurrency, location: location,
                         postalAddress: postalAddress, languageCode: languageCode, category: actualCategory,
                         status: actualStatus, thumbnail: actualThumbnail, thumbnailSize: thumbnailSize,
                         images: actualImages, user: user)
    }
}

// Designated initializers
extension LGProduct {
    public init(product: Product) {
        self.objectId = product.objectId
        self.updatedAt = product.updatedAt
        self.createdAt = product.createdAt
        self.name = product.name
        self.nameAuto = product.nameAuto
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
        self.favorite = product.favorite
    }
}

//String convertible
extension LGProduct: CustomStringConvertible {
    public var description: String {

        return "name: \(name); nameAuto: \(nameAuto); descr: \(descr); price: \(price); currency: \(currency); location: \(location); postalAddress: \(postalAddress); languageCode: \(languageCode); category: \(category); status: \(status); thumbnail: \(thumbnail); thumbnailSize: \(thumbnailSize); images: \(images); user: \(user); descr: \(descr);"
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
        let geo: JSON? = j.decode("geo")
        let init1 = curry(LGProduct.productWithId)
                            <^> j <|? "id"                                          // objectId : String?
                            <*> j <|? "updated_at"                                  // updatedAt : NSDate?
                            <*> j <|? "created_at"                                  // createdAt : NSDate?
                            <*> j <|? "name"                                        // name : String?
        let init2 = init1   <*> j <|? "image_information"                           // nameAuto : String?
                            <*> j <|? "description"                                 // descr : String?
                            <*> j <|? "price"                                       // price : Float?
                            <*> j <| "currency"                                    // currency : String?
        let init3 = init2   <*> LGArgo.jsonToCoordinates(geo, latKey: "lat", lonKey: "lng") // location : LGLocationCoordinates2D?
                            <*> j <| "geo"                                          // postalAddress : PostalAddress
                            <*> j <|? "language_code"                               // languageCode : String?
        let init4 = init3   <*> j <| "category_id"                                  // category_id : Int
                            <*> j <| "status"                                       // status : Int
                            <*> j <|? ["thumb", "url"]                              // thumbnail : String?
        let result = init4  <*> j <|? "thumb"                                       // thumbnailSize : LGSize?
                            <*> (j <||? "images" >>- LGArgo.jsonArrayToFileArray)   // images : [LGFile]
                            <*> j <| "owner"                                        // user : LGUser?

        if let error = result.error {
            print("LGProduct parse error: \(error)")
        }

        return result
    }
}
