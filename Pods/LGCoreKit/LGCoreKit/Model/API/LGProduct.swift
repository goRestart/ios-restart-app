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
    let objectId: String?
    let updatedAt: Date?
    let createdAt: Date?

    // Product iVars
    let name: String?
    let nameAuto: String?
    let descr: String?
    let price: ListingPrice
    let currency: Currency

    let location: LGLocationCoordinates2D
    let postalAddress: PostalAddress

    let languageCode: String?

    let category: ListingCategory
    let status: ListingStatus

    let thumbnail: File?
    let thumbnailSize: LGSize?
    let images: [File]

    var user: UserListing

    let featured: Bool?

    // This parameters is not included in the API, we set a default value that must be changed if needed once 
    // the object is created after the decoding.
    var favorite: Bool = false

    init(product: Product) {
        self.init(objectId: product.objectId, updatedAt: product.updatedAt, createdAt: product.createdAt,
                  name: product.name, nameAuto: product.nameAuto, descr: product.descr, price: product.price,
                  currency: product.currency, location: product.location, postalAddress: product.postalAddress,
                  languageCode: product.languageCode, category: product.category, status: product.status,
                  thumbnail: product.thumbnail, thumbnailSize: product.thumbnailSize,
                  images: product.images, user: product.user, featured: product.featured)
        self.favorite = product.favorite
    }

    init(objectId: String?, updatedAt: Date?, createdAt: Date?, name: String?, nameAuto: String?, descr: String?,
         price: ListingPrice, currency: Currency, location: LGLocationCoordinates2D, postalAddress: PostalAddress,
         languageCode: String?, category: ListingCategory, status: ListingStatus, thumbnail: File?,
         thumbnailSize: LGSize?, images: [File], user: UserListing, featured: Bool?) {
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
        self.featured = featured ?? false
        self.favorite = false
    }
    
    init(chatListing: ChatListing, chatInterlocutor: ChatInterlocutor) {
        let user = LGUserListing(chatInterlocutor: chatInterlocutor)
        let images = [chatListing.image].flatMap{$0}
        let location = LGLocationCoordinates2D(latitude: 0, longitude: 0)
        let postalAddress = PostalAddress.emptyAddress()
        let category = ListingCategory.other
        
        self.init(objectId: chatListing.objectId, updatedAt: nil, createdAt: nil, name: chatListing.name,
                  nameAuto: nil, descr: nil, price: chatListing.price, currency: chatListing.currency, location: location,
                  postalAddress: postalAddress, languageCode: nil, category: category,
                  status: chatListing.status, thumbnail: chatListing.image, thumbnailSize: nil,
                  images: images, user: user, featured: nil)
    }
    
    static func productWithId(_ objectId: String?, updatedAt: Date?, createdAt: Date?, name: String?,
                              nameAuto: String?, descr: String?, price: Double?, priceFlag: ListingPriceFlag?, currency: String,
                              location: LGLocationCoordinates2D, postalAddress: PostalAddress, languageCode: String?,
                              category: Int, status: Int, thumbnail: String?, thumbnailSize: LGSize?, images: [LGFile],
                              user: LGUserListing, featured: Bool?) -> LGProduct {
        let actualCurrency = Currency.currencyWithCode(currency)
        let actualCategory = ListingCategory(rawValue: category) ?? .other
        let actualStatus = ListingStatus(rawValue: status) ?? .pending
        let actualThumbnail = LGFile(id: nil, urlString: thumbnail)
        let actualImages = images.flatMap { $0 as File }
        let listingPrice = ListingPrice.fromPrice(price, andFlag: priceFlag)
        
        return self.init(objectId: objectId, updatedAt: updatedAt, createdAt: createdAt, name: name,
                         nameAuto: nameAuto, descr: descr, price: listingPrice, currency: actualCurrency, location: location,
                         postalAddress: postalAddress, languageCode: languageCode, category: actualCategory,
                         status: actualStatus, thumbnail: actualThumbnail, thumbnailSize: thumbnailSize,
                         images: actualImages, user: user, featured: featured)
    }
    
    // MARK: Updates
    
    func updating(category: ListingCategory) -> LGProduct {
        return LGProduct(objectId: objectId, updatedAt: updatedAt, createdAt: createdAt, name: name,
                         nameAuto: nameAuto, descr: descr, price: price, currency: currency,
                         location: location, postalAddress: postalAddress, languageCode: languageCode,
                         category: category, status: status, thumbnail: thumbnail,
                         thumbnailSize: thumbnailSize, images: images, user: user, featured: featured)
    }
    
    func updating(status: ListingStatus) -> LGProduct {
        return LGProduct(objectId: objectId, updatedAt: updatedAt, createdAt: createdAt, name: name,
                         nameAuto: nameAuto, descr: descr, price: price, currency: currency,
                         location: location, postalAddress: postalAddress, languageCode: languageCode,
                         category: category, status: status, thumbnail: thumbnail,
                         thumbnailSize: thumbnailSize, images: images, user: user, featured: featured)
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
			"image_information": "black fitbit wireless activity wristband",
            "featured": false
		}
    */
    static func decode(_ j: JSON) -> Decoded<LGProduct> {
        let geo: JSON? = j.decode("geo")
        let result01 = curry(LGProduct.productWithId)
        let result02 = result01 <^> j <|? "id"                                          // objectId : String?
        let result03 = result02 <*> j <|? "updated_at"                                  // updatedAt : Date?
        let result04 = result03 <*> j <|? "created_at"                                  // createdAt : Date?
        let result05 = result04 <*> j <|? "name"                                        // name : String?
        let result06 = result05 <*> j <|? "image_information"                           // nameAuto : String?
        let result07 = result06 <*> j <|? "description"                                 // descr : String?
        let result08 = result07 <*> j <|? "price"                                       // price : Float?
        let result09 = result08 <*> j <|? "price_flag"
        let result10 = result09 <*> j <| "currency"                                     // currency : String?
        let result11 = result10 <*> LGArgo.jsonToCoordinates(geo, latKey: "lat", lonKey: "lng") // location : LGLocationCoordinates2D?
        let result12 = result11 <*> j <| "geo"                                          // postalAddress : PostalAddress
        let result13 = result12 <*> j <|? "language_code"                               // languageCode : String?
        let result14 = result13 <*> j <| "category_id"                                  // category_id : Int
        let result15 = result14 <*> j <| "status"                                       // status : Int
        let result16 = result15 <*> j <|? ["thumb", "url"]                              // thumbnail : String?
        let result17 = result16 <*> j <|? "thumb"                                       // thumbnailSize : LGSize?
        let result18 = result17 <*> (j <||? "images" >>- LGArgo.jsonArrayToFileArray)   // images : [LGFile]
        let result19 = result18 <*> j <| "owner"                                        // user : LGUserListing?
        let result   = result19 <*> j <|? "featured"                                    // featured : Bool
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGProduct parse error: \(error)")
        }
        return result
    }
}
