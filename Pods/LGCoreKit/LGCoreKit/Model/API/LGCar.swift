//
//  LGCar.swift
//  LGCoreKit
//
//  Created by Nestor on 21/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol Car: BaseListingModel {
    var carAttributes: CarAttributes { get }
}

struct LGCar: Car, Decodable {

    let objectId: String?
    let updatedAt: Date?
    let createdAt: Date?
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
    var media: [Media]
    var mediaThumbnail: MediaThumbnail?
    var user: UserListing
    let featured: Bool?
    let carAttributes: CarAttributes
    
    init(car: Car) {
        self.init(objectId: car.objectId,
                  updatedAt: car.updatedAt,
                  createdAt: car.createdAt,
                  name: car.name,
                  nameAuto: car.nameAuto,
                  descr: car.descr,
                  price: car.price,
                  currency: car.currency,
                  location: car.location,
                  postalAddress: car.postalAddress,
                  languageCode: car.languageCode,
                  category: car.category,
                  status: car.status,
                  thumbnail: car.thumbnail,
                  thumbnailSize: car.thumbnailSize,
                  images: car.images,
                  media: car.media,
                  mediaThumbnail: car.mediaThumbnail,
                  user: car.user,
                  featured: car.featured,
                  carAttributes: car.carAttributes)
    }
    
    init(objectId: String?,
         updatedAt: Date?,
         createdAt: Date?,
         name: String?,
         nameAuto: String?,
         descr: String?,
         price: ListingPrice,
         currency: Currency,
         location: LGLocationCoordinates2D,
         postalAddress: PostalAddress,
         languageCode: String?,
         category: ListingCategory,
         status: ListingStatus,
         thumbnail: File?,
         thumbnailSize: LGSize?,
         images: [File],
         media: [Media],
         mediaThumbnail: MediaThumbnail?,
         user: UserListing,
         featured: Bool?,
         carAttributes: CarAttributes?) {
        
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
        self.media = media
        self.mediaThumbnail = mediaThumbnail
        self.user = user
        self.featured = featured ?? false
        self.carAttributes = carAttributes ?? CarAttributes.emptyCarAttributes()
    }
    
    init(chatListing: ChatListing, chatInterlocutor: ChatInterlocutor) {
        let user = LGUserListing(chatInterlocutor: chatInterlocutor)
        let images = [chatListing.image].compactMap{$0}
        let location = LGLocationCoordinates2D(latitude: 0, longitude: 0)
        let postalAddress = PostalAddress.emptyAddress()
        let category = ListingCategory.other
        
        self.init(objectId: chatListing.objectId,
                  updatedAt: nil,
                  createdAt: nil,
                  name: chatListing.name,
                  nameAuto: nil,
                  descr: nil,
                  price: chatListing.price,
                  currency: chatListing.currency,
                  location: location,
                  postalAddress: postalAddress,
                  languageCode: nil,
                  category: category,
                  status: chatListing.status,
                  thumbnail: chatListing.image,
                  thumbnailSize: nil,
                  images: images,
                  media: [],
                  mediaThumbnail: nil,
                  user: user,
                  featured: nil,
                  carAttributes: CarAttributes.emptyCarAttributes()
                  )
    }
    
    static func carWithId(_ objectId: String?,
                          updatedAt: Date?,
                          createdAt: Date?,
                          name: String?,
                          nameAuto: String?,
                          descr: String?,
                          price: Double?,
                          priceFlag: ListingPriceFlag?,
                          currency: String,
                          location: LGLocationCoordinates2D,
                          postalAddress: PostalAddress,
                          languageCode: String?,
                          category: Int,
                          status: ListingStatus,
                          thumbnail: String?,
                          thumbnailSize: LGSize?,
                          images: [LGFile],
                          media: [Media],
                          mediaThumbnail: MediaThumbnail?,
                          user: LGUserListing,
                          featured: Bool?,
                          carAttributes: CarAttributes?) -> LGCar {
        let actualCurrency = Currency.currencyWithCode(currency)
        let actualCategory = ListingCategory(rawValue: category) ?? .other
        let actualThumbnail = LGFile(id: nil, urlString: thumbnail)
        let actualImages = images.compactMap { $0 as File }
        let listingPrice = ListingPrice.fromPrice(price, andFlag: priceFlag)
        
        return self.init(objectId: objectId,
                         updatedAt: updatedAt,
                         createdAt: createdAt,
                         name: name,
                         nameAuto: nameAuto,
                         descr: descr,
                         price: listingPrice,
                         currency: actualCurrency,
                         location: location,
                         postalAddress: postalAddress,
                         languageCode: languageCode,
                         category: actualCategory,
                         status: status,
                         thumbnail: actualThumbnail,
                         thumbnailSize: thumbnailSize,
                         images: actualImages,
                         media: media,
                         mediaThumbnail: mediaThumbnail,
                         user: user,
                         featured: featured,
                         carAttributes: carAttributes)
    }
    
    // MARK: Updates
    
    func updating(category: ListingCategory) -> LGCar {
        return LGCar(objectId: objectId,
                     updatedAt: updatedAt,
                     createdAt: createdAt,
                     name: name,
                     nameAuto: nameAuto,
                     descr: descr, price: price,
                     currency: currency,
                     location: location,
                     postalAddress: postalAddress,
                     languageCode: languageCode,
                     category: category,
                     status: status,
                     thumbnail: thumbnail,
                     thumbnailSize: thumbnailSize,
                     images: images,
                     media: media,
                     mediaThumbnail: mediaThumbnail,
                     user: user,
                     featured: featured,
                     carAttributes: carAttributes)
    }
    
    func updating(status: ListingStatus) -> LGCar {
        return LGCar(objectId: objectId,
                     updatedAt: updatedAt,
                     createdAt: createdAt,
                     name: name,
                     nameAuto: nameAuto,
                     descr: descr,
                     price: price,
                     currency: currency,
                     location: location,
                     postalAddress: postalAddress,
                     languageCode: languageCode,
                     category: category,
                     status: status,
                     thumbnail: thumbnail,
                     thumbnailSize: thumbnailSize,
                     images: images,
                     media: media,
                     mediaThumbnail: mediaThumbnail,
                     user: user,
                     featured: featured,
                     carAttributes: carAttributes)
    }
    
    func updating(carAttributes: CarAttributes) -> LGCar {
        return LGCar(objectId: objectId,
                     updatedAt: updatedAt,
                     createdAt: createdAt,
                     name: name,
                     nameAuto: nameAuto,
                     descr: descr,
                     price: price,
                     currency: currency,
                     location: location,
                     postalAddress: postalAddress,
                     languageCode: languageCode,
                     category: category,
                     status: status,
                     thumbnail: thumbnail,
                     thumbnailSize: thumbnailSize,
                     images: images,
                     media: media,
                     mediaThumbnail: mediaThumbnail,
                     user: user,
                     featured: featured,
                     carAttributes: carAttributes)
    }
    
    // MARK: - Decodable
    
    /*
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
            "make": "4b301c13-9e5f-442a-a63b-affd15f9268e",
            "model": "3705d6fe-4c63-424a-929c-64c7b715b620",
            "year": 2000
         }
     }
     */
    
    public init(from decoder: Decoder) throws {
        let baseListing = try LGBaseListing(from: decoder)
        objectId = baseListing.objectId
        updatedAt = baseListing.updatedAt
        createdAt = baseListing.createdAt
        name = baseListing.name
        nameAuto = baseListing.nameAuto
        descr = baseListing.descr
        price = baseListing.price
        currency = baseListing.currency
        location = baseListing.location
        postalAddress = baseListing.postalAddress
        languageCode = baseListing.languageCode
        category = baseListing.category
        status = baseListing.status
        thumbnail = baseListing.thumbnail
        thumbnailSize = baseListing.thumbnailSize
        images = baseListing.images
        media = baseListing.media.isEmpty ? LGMedia.mediaFrom(images: baseListing.images) : baseListing.media
        mediaThumbnail = baseListing.mediaThumbnail
        user = baseListing.user
        featured = baseListing.featured
        
        let keyedContainerApi = try decoder.container(keyedBy: CodingKeysApi.self)
        let keyedContainerVerticals = try decoder.container(keyedBy: CodingKeysVerticals.self)
        
        if let attributes = try keyedContainerApi.decodeIfPresent(CarAttributes.self, forKey: .carAttributes) {
            carAttributes = attributes
        } else {
            carAttributes = try keyedContainerVerticals.decodeIfPresent(CarAttributes.self, forKey: .carAttributes) ?? CarAttributes.emptyCarAttributes()
        }
        
    }
    
    enum CodingKeysApi: String, CodingKey {
        case carAttributes = "attributes"
    }
    enum CodingKeysVerticals: String, CodingKey {
        case carAttributes = "carAttributes"
    }
}
