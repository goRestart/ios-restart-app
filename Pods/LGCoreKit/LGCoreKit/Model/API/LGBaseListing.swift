//
//  LGBaseListing.swift
//  LGCoreKit
//
//  Created by Nestor on 17/11/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

struct LGBaseListing: BaseListingModel, Decodable {
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
    var user: UserListing
    let featured: Bool?

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
        self.user = user
        self.featured = featured ?? false
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
     "featured": false,
     "rejected_reason": null
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = LGDateFormatter()

        objectId = try keyedContainer.decodeIfPresent(String.self, forKey: .objectId)
        if let updatedAtString = try keyedContainer.decodeIfPresent(String.self, forKey: .updatedAt),
            let updatedAt = dateFormatter.date(from: updatedAtString) {
            self.updatedAt = updatedAt
        } else {
            self.updatedAt = nil
        }
        if let createdAtString = try keyedContainer.decodeIfPresent(String.self, forKey: .createdAt),
            let createdAt = dateFormatter.date(from: createdAtString) {
            self.createdAt = createdAt
        } else {
            self.createdAt = nil
        }

        name = try keyedContainer.decodeIfPresent(String.self, forKey: .name)
        nameAuto = try keyedContainer.decodeIfPresent(String.self, forKey: .nameAuto)
        descr = try keyedContainer.decodeIfPresent(String.self, forKey: .descr)

        let priceValue = try keyedContainer.decodeIfPresent(Double.self, forKey: .price)
        let priceFlag: ListingPriceFlag?
        if let priceFlagRawValue = try keyedContainer.decodeIfPresent(Int.self, forKey: .priceFlag) {
            priceFlag = ListingPriceFlag(rawValue: priceFlagRawValue)
        } else {
            priceFlag = nil
        }
        price = ListingPrice.fromPrice(priceValue, andFlag: priceFlag)

        let currencyCode = try keyedContainer.decode(String.self, forKey: .currency)
        currency = Currency.currencyWithCode(currencyCode)

        let locationKeyedContainer = try keyedContainer.nestedContainer(keyedBy: LocationCodingKeys.self,
                                                                        forKey: .location)
        let latitude = try locationKeyedContainer.decode(Double.self, forKey: .latitude)
        let longitude = try locationKeyedContainer.decode(Double.self, forKey: .longitude)
        location = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
        postalAddress = try keyedContainer.decode(PostalAddress.self, forKey: .location)

        languageCode = try keyedContainer.decodeIfPresent(String.self, forKey: .languageCode)
        let categoryRawValue = try keyedContainer.decode(Int.self, forKey: .categoryId)
        category = ListingCategory(rawValue: categoryRawValue) ?? .unassigned

        let code = try keyedContainer.decode(Int.self, forKey: .status)
        let statusCode = ListingStatusCode(rawValue: code) ?? .approved
        let discardedReason = try keyedContainer.decodeIfPresent(DiscardedReason.self, forKey: .discardedReason)
        status = ListingStatus(statusCode: statusCode, discardedReason: discardedReason) ?? .pending

        let thumbnailKeyedContainer = try keyedContainer.nestedContainer(keyedBy: ThumbnailCodingKeys.self, forKey: .thumbnail)
        let thumbnailUrl = try thumbnailKeyedContainer.decodeIfPresent(String.self, forKey: .url)
        thumbnail = LGFile(id: nil, urlString: thumbnailUrl)
        if let thumbnailWidth = try thumbnailKeyedContainer.decodeIfPresent(Float.self, forKey: .width),
            let thumbnailHeight = try thumbnailKeyedContainer.decodeIfPresent(Float.self, forKey: .height) {
            thumbnailSize = LGSize(width: thumbnailWidth, height: thumbnailHeight)
        } else {
            thumbnailSize = nil
        }

        let imagesArray = (try keyedContainer.decode(FailableDecodableArray<LGListingImage>.self, forKey: .images)).validElements
        images = LGListingImage.mapToFiles(imagesArray)

        user = try keyedContainer.decode(LGUserListing.self, forKey: .user)
        featured = try keyedContainer.decodeIfPresent(Bool.self, forKey: .featured)
    }

    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case name = "name"
        case nameAuto = "image_information"
        case descr = "description"
        case price = "price"
        case priceFlag = "price_flag"
        case currency = "currency"
        case location = "geo"
        case languageCode = "language_code"
        case categoryId = "category_id"
        case status = "status"
        case thumbnail = "thumb"
        case images = "images"
        case user = "owner"
        case featured = "featured"
        case discardedReason = "rejected_reason"
    }

    enum LocationCodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
        case countryCode = "country_code"
        case city
        case zipCode = "zip_code"
    }

    enum ThumbnailCodingKeys: String, CodingKey {
        case url
        case width
        case height
    }
}
