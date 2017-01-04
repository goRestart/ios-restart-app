//
//  LGPartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGProduct: Product {

    // Global iVars
    var objectId: String?
    var updatedAt: Date?
    var createdAt: Date?

    // Product iVars
    var name: String?
    var nameAuto: String?
    var descr: String?
    var price: ProductPrice
    var currency: Currency

    var location: LGLocationCoordinates2D
    var postalAddress: PostalAddress

    var languageCode: String?

    var category: ProductCategory
    var status: ProductStatus

    var thumbnail: File?
    var thumbnailSize: LGSize?
    var images: [File]

    var user: User

    // This parameters is not included in the API, we set a default value that must be changed if needed once 
    // the object is created after the decoding.
    var favorite: Bool = false

    init(objectId: String?, updatedAt: Date?, createdAt: Date?, name: String?, nameAuto: String?, descr: String?,
         price: ProductPrice, currency: Currency, location: LGLocationCoordinates2D, postalAddress: PostalAddress,
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
    
    init(chatProduct: ChatProduct, chatInterlocutor: ChatInterlocutor) {
        let user = LGUser(chatInterlocutor: chatInterlocutor)
        let images = [chatProduct.image].flatMap{$0}
        let location = LGLocationCoordinates2D(latitude: 0, longitude: 0)
        let postalAddress = PostalAddress.emptyAddress()
        let category = ProductCategory.other
        
        self.init(objectId: chatProduct.objectId, updatedAt: nil, createdAt: nil, name: chatProduct.name,
                  nameAuto: nil, descr: nil, price: chatProduct.price, currency: chatProduct.currency, location: location,
                  postalAddress: postalAddress, languageCode: nil, category: category,
                  status: chatProduct.status, thumbnail: chatProduct.image, thumbnailSize: nil,
                  images: images, user: user)
    }
    
    static func productWithId(_ objectId: String?, updatedAt: Date?, createdAt: Date?, name: String?,
                              nameAuto: String?, descr: String?, price: Double?, priceFlag: ProductPriceFlag?, currency: String,
                              location: LGLocationCoordinates2D, postalAddress: PostalAddress, languageCode: String?,
                              category: Int, status: Int, thumbnail: String?, thumbnailSize: LGSize?, images: [LGFile],
                              user: LGUser) -> LGProduct {
        let actualCurrency = Currency.currencyWithCode(currency)
        let actualCategory = ProductCategory(rawValue: category) ?? .other
        let actualStatus = ProductStatus(rawValue: status) ?? .pending
        let actualThumbnail = LGFile(id: nil, urlString: thumbnail)
        let actualImages = images.flatMap { $0 as File }
        let productPrice = ProductPrice.fromPrice(price, andFlag: priceFlag)
        
        return self.init(objectId: objectId, updatedAt: updatedAt, createdAt: createdAt, name: name,
                         nameAuto: nameAuto, descr: descr, price: productPrice, currency: actualCurrency, location: location,
                         postalAddress: postalAddress, languageCode: languageCode, category: actualCategory,
                         status: actualStatus, thumbnail: actualThumbnail, thumbnailSize: thumbnailSize,
                         images: actualImages, user: user)
    }
}

// Designated initializers
extension LGProduct {
    init(product: Product) {
        self.init(objectId: product.objectId, updatedAt: product.updatedAt as Date?, createdAt: product.createdAt as Date?,
                  name: product.name, nameAuto: product.nameAuto, descr: product.descr, price: product.price,
                  currency: product.currency, location: product.location, postalAddress: product.postalAddress,
                  languageCode: product.languageCode, category: product.category, status: product.status,
                  thumbnail: product.thumbnail, thumbnailSize: product.thumbnailSize,
                  images: product.images, user: product.user)
        self.favorite = product.favorite
    }
}

//String convertible
extension LGProduct: CustomStringConvertible {
    var description: String {

        return "name: \(name); nameAuto: \(nameAuto); descr: \(descr); price: \(price); currency: \(currency); location: \(location); postalAddress: \(postalAddress); languageCode: \(languageCode); category: \(category); status: \(status); thumbnail: \(thumbnail); thumbnailSize: \(thumbnailSize); images: \(images); user: \(user); descr: \(descr);"
    }
}

extension ProductPriceFlag: Decodable {}

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
			"price_flag": 1,   // Can be 0 (normal), 1 (free), 2 (Negotiable), 3 (Firm price)
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
    static func decode(_ j: JSON) -> Decoded<LGProduct> {
        let geo: JSON? = j.decode("geo")
        let init1 = curry(LGProduct.productWithId)
                            <^> j <|? "id"                                          // objectId : String?
                            <*> j <|? "updated_at"                                  // updatedAt : NSDate?
                            <*> j <|? "created_at"                                  // createdAt : NSDate?
                            <*> j <|? "name"                                        // name : String?
        let init2 = init1   <*> j <|? "image_information"                           // nameAuto : String?
                            <*> j <|? "description"                                 // descr : String?
                            <*> j <|? "price"                                       // price : Float?
                            <*> j <|? "price_flag"
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
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "LGProduct parse error: \(error)")
        }

        return result
    }
}
