//
//  LGCar.swift
//  LGCoreKit
//
//  Created by Nestor on 21/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGCar: Car {
    
    // Global iVars
    let objectId: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    // Listing iVars
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
    
    // Car iVars
    let make: String?
    let makeId: String?
    let model: String?
    let modelId: String?
    let year: Int?
    
    init(car: Car) {
        self.init(objectId: car.objectId, updatedAt: car.updatedAt, createdAt: car.createdAt, name: car.name,
                  nameAuto: car.nameAuto, descr: car.descr, price: car.price, currency: car.currency,
                  location: car.location, postalAddress: car.postalAddress, languageCode: car.languageCode,
                  category: car.category, status: car.status, thumbnail: car.thumbnail, thumbnailSize: car.thumbnailSize,
                  images: car.images, user: car.user, featured: car.featured, make: car.make, makeId: car.makeId,
                  model: car.model, modelId: car.modelId, year: car.year)
        self.favorite = car.favorite
    }
    
    init(objectId: String?, updatedAt: Date?, createdAt: Date?, name: String?, nameAuto: String?, descr: String?,
         price: ListingPrice, currency: Currency, location: LGLocationCoordinates2D, postalAddress: PostalAddress,
         languageCode: String?, category: ListingCategory, status: ListingStatus, thumbnail: File?,
         thumbnailSize: LGSize?, images: [File], user: UserListing, featured: Bool?, make: String?, makeId: String?,
         model: String?, modelId: String?, year: Int?) {
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
        self.make = make
        self.makeId = makeId
        self.model = model
        self.modelId = modelId
        self.year = year
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
                  images: images, user: user, featured: nil, make: nil, makeId: nil, model: nil, modelId: nil, year: nil)
    }
    
    static func carWithId(_ objectId: String?, updatedAt: Date?, createdAt: Date?, name: String?,
                              nameAuto: String?, descr: String?, price: Double?, priceFlag: ListingPriceFlag?, currency: String,
                              location: LGLocationCoordinates2D, postalAddress: PostalAddress, languageCode: String?,
                              category: Int, status: Int, thumbnail: String?, thumbnailSize: LGSize?, images: [LGFile],
                              user: LGUserListing, featured: Bool?, carAttributes: CarAttributes?) -> LGCar {
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
                         images: actualImages, user: user, featured: featured, make: carAttributes?.make,
                         makeId: carAttributes?.makeId, model: carAttributes?.model, modelId: carAttributes?.modelId,
                         year: carAttributes?.year)
    }
    
    // MARK: Updates
    
    func updating(category: ListingCategory) -> LGCar {
        return LGCar(objectId: objectId, updatedAt: updatedAt, createdAt: createdAt, name: name,
                         nameAuto: nameAuto, descr: descr, price: price, currency: currency,
                         location: location, postalAddress: postalAddress, languageCode: languageCode,
                         category: category, status: status, thumbnail: thumbnail,
                         thumbnailSize: thumbnailSize, images: images, user: user, featured: featured, make: make,
                         makeId: makeId, model: model, modelId: modelId, year: year)
    }
    
    func updating(status: ListingStatus) -> LGCar {
        return LGCar(objectId: objectId, updatedAt: updatedAt, createdAt: createdAt, name: name,
                     nameAuto: nameAuto, descr: descr, price: price, currency: currency,
                     location: location, postalAddress: postalAddress, languageCode: languageCode,
                     category: category, status: status, thumbnail: thumbnail,
                     thumbnailSize: thumbnailSize, images: images, user: user, featured: featured, make: make,
                     makeId: makeId, model: model, modelId: modelId, year: year)
    }
}

extension LGCar : Decodable {
    
    struct CarAttributes: Decodable {
        let make: String?
        let makeId: String?
        let model: String?
        let modelId: String?
        let year: Int?
        
        /**
         Expects a json in the form:
         
         {
             "make": {
                "id": "4b301c13-9e5f-442a-a63b-affd15f9268e",
                "name": "Audi"
             },
             "model": {
                "id": "3705d6fe-4c63-424a-929c-64c7b715b620",
                "name": "A1"
             },
             "year": 2000
         }
         
         */
        static func decode(_ j: JSON) -> Decoded<CarAttributes> {
            let init1 = curry(CarAttributes.init)
                                <^> j <|? ["make", "id"]
                                <*> j <|? ["make", "name"]
            let init2 = init1   <*> j <|? ["model", "id"]
                                <*> j <|? ["model", "name"]
                                <*> j <|? "year"
            return init2
        }
    }
    
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
         "attributes": {
             "make": {
                 "id": "4b301c13-9e5f-442a-a63b-affd15f9268e",
                 "name": "Audi"
             },
             "model": {
                 "id": "3705d6fe-4c63-424a-929c-64c7b715b620",
                 "name": "A1"
             },
             "year": 2000
         }
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGCar> {
        guard let category_id: Int = j.decode("category_id"),
            let category = ListingCategory(rawValue: category_id), category.isCar else {
                logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGCar parse error: category_id is not valid")
                return Decoded<LGCar>.failure(DecodeError.custom("category_id: is not valid"))
        }
        let geo: JSON? = j.decode("geo")
        let init1 = curry(LGCar.carWithId)
                            <^> j <|? "id"                                          // objectId : String?
                            <*> j <|? "updated_at"                                  // updatedAt : Date?
                            <*> j <|? "created_at"                                  // createdAt : Date?
        let init2 = init1   <*> j <|? "name"                                        // name : String?
                            <*> j <|? "image_information"                           // nameAuto : String?
                            <*> j <|? "description"                                 // descr : String?
                            <*> j <|? "price"                                       // price : Float?
        let init3 = init2   <*> j <|? "price_flag"
                            <*> j <| "currency"                                    // currency : String?
                            <*> LGArgo.jsonToCoordinates(geo, latKey: "lat", lonKey: "lng") // location : LGLocationCoordinates2D?
                            <*> j <| "geo"                                          // postalAddress : PostalAddress
        let init4 = init3   <*> j <|? "language_code"                               // languageCode : String?
                            <*> j <| "category_id"                                  // category_id : Int
                            <*> j <| "status"                                       // status : Int
                            <*> j <|? ["thumb", "url"]                              // thumbnail : String?
        let result = init4  <*> j <|? "thumb"                                       // thumbnailSize : LGSize?
                            <*> (j <||? "images" >>- LGArgo.jsonArrayToFileArray)   // images : [LGFile]
                            <*> j <| "owner"                                        // user : LGUserListing?
                            <*> j <|? "featured"                                    // featured : Bool
        let car = result    <*> j <|? "attributes"                                  // carAttributes : CarAttributes
        
        if let error = car.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGCar parse error: \(error)")
        }
        
        return car
    }
}

