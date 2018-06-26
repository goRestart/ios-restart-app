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
    var media: [Media]
    var mediaThumbnail: MediaThumbnail?
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
        let keyedContainerProductsApi = try decoder.container(keyedBy: CodingKeysProductsApi.self)
        let keyedContainerVerticalsApi = try decoder.container(keyedBy: CodingKeysVerticalsApi.self)
        let keyedContainerBase = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = LGDateFormatter()

        objectId = try keyedContainerBase.decodeIfPresent(String.self, forKey: .objectId)
        
        var updatedDateValue: Date? = nil
        if let updatedAtProductsApi = try keyedContainerProductsApi.decodeIfPresent(String.self, forKey: .updatedAt)
             {
            updatedDateValue = dateFormatter.date(from: updatedAtProductsApi)
        } else if let updatedAtVerticalsApi = try keyedContainerVerticalsApi.decodeIfPresent(String.self, forKey: .updatedAt) {
            updatedDateValue = dateFormatter.date(from: updatedAtVerticalsApi)
        }
        self.updatedAt = updatedDateValue
        
        var createdAtDateValue: Date?
        if let createdAtProductsApi = try keyedContainerProductsApi.decodeIfPresent(String.self, forKey: .createdAt)
        {
            createdAtDateValue = dateFormatter.date(from: createdAtProductsApi)
        } else if let createdAtVerticalsApi = try keyedContainerVerticalsApi.decodeIfPresent(String.self, forKey: .createdAt) {
            createdAtDateValue = dateFormatter.date(from: createdAtVerticalsApi)
        }
        self.createdAt = createdAtDateValue
        

        name = try keyedContainerBase.decodeIfPresent(String.self, forKey: .name)
        
        if let nameAutoValue = try keyedContainerProductsApi.decodeIfPresent(String.self, forKey: .nameAuto) {
            nameAuto = nameAutoValue
        } else {
            nameAuto = try keyedContainerVerticalsApi.decodeIfPresent(String.self, forKey: .nameAuto)
        }
        
        descr = try keyedContainerBase.decodeIfPresent(String.self, forKey: .descr)

        var priceValue: Double? = nil
        priceValue = try keyedContainerBase.decodeIfPresent(Double.self, forKey: .price)
        
        var priceFlag: ListingPriceFlag? = nil
        if let priceFlagProductsRawValue = try keyedContainerProductsApi.decodeIfPresent(Int.self, forKey: .priceFlag) {
            priceFlag = ListingPriceFlag(rawValue: priceFlagProductsRawValue)
        } else if let priceFlagVerticalsRawValue = try keyedContainerVerticalsApi.decodeIfPresent(Int.self, forKey: .priceFlag) {
            priceFlag = ListingPriceFlag(rawValue: priceFlagVerticalsRawValue)
        }
        price = ListingPrice.fromPrice(priceValue, andFlag: priceFlag)

        let currencyCode = try keyedContainerBase.decode(String.self, forKey: .currency)
        currency = Currency.currencyWithCode(currencyCode)

        let locationKeyedContainerProductsApi = try keyedContainerBase.nestedContainer(keyedBy: LocationCodingKeysProductsApi.self,
                                                                        forKey: .location)
        let locationKeyedContainerVerticalsApi = try keyedContainerBase.nestedContainer(keyedBy: LocationCodingKeysVerticalsApi.self,
                                                                                              forKey: .location)
        
        let latitude: Double
        if let latitudeProductsApi = try locationKeyedContainerProductsApi.decodeIfPresent(Double.self, forKey: .latitude) {
            latitude = latitudeProductsApi
        } else {
            latitude = try locationKeyedContainerVerticalsApi.decode(Double.self, forKey: .latitude)
        }
        
        let longitude: Double
        if let longitudeProductsApi = try locationKeyedContainerProductsApi.decodeIfPresent(Double.self, forKey: .longitude) {
            longitude = longitudeProductsApi
        } else {
            longitude = try locationKeyedContainerVerticalsApi.decode(Double.self, forKey: .longitude)
        }
        
        location = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
        
        postalAddress = try keyedContainerBase.decode(PostalAddress.self, forKey: .location)

        if let languageCodeValue = try keyedContainerProductsApi.decodeIfPresent(String.self, forKey: .languageCode) {
            languageCode = languageCodeValue
        } else {
            languageCode = try keyedContainerVerticalsApi.decodeIfPresent(String.self, forKey: .languageCode)
        }
        
        if let categoryRawValue = try keyedContainerProductsApi.decodeIfPresent(Int.self, forKey: .categoryId) {
            category = ListingCategory(rawValue: categoryRawValue) ?? .unassigned
        } else {
            let categoryValue = try keyedContainerVerticalsApi.decode(Int.self, forKey: .categoryId)
            category = ListingCategory(rawValue: categoryValue) ?? .unassigned
        }
        
        let code = try keyedContainerBase.decode(Int.self, forKey: .status)
        let statusCode = ListingStatusCode(rawValue: code) ?? .approved
        
        let discardReason: DiscardedReason?
        if let discardedReasonValue = try keyedContainerProductsApi.decodeIfPresent(DiscardedReason.self, forKey: .discardedReason) {
            discardReason = discardedReasonValue
        } else {
            discardReason = try keyedContainerProductsApi.decodeIfPresent(DiscardedReason.self, forKey: .discardedReason)
        }
        status = ListingStatus(statusCode: statusCode, discardedReason: discardReason) ?? .pending

        let thumbnailKeyedContainer = try keyedContainerBase.nestedContainer(keyedBy: ThumbnailCodingKeys.self, forKey: .thumbnail)
        let thumbnailUrl = try thumbnailKeyedContainer.decodeIfPresent(String.self, forKey: .url)
        thumbnail = LGFile(id: nil, urlString: thumbnailUrl)
        if let thumbnailWidth = try thumbnailKeyedContainer.decodeIfPresent(Float.self, forKey: .width),
            let thumbnailHeight = try thumbnailKeyedContainer.decodeIfPresent(Float.self, forKey: .height) {
            thumbnailSize = LGSize(width: thumbnailWidth, height: thumbnailHeight)
        } else {
            thumbnailSize = nil
        }

        let imagesArray = (try keyedContainerBase.decode(FailableDecodableArray<LGListingImage>.self, forKey: .images)).validElements
        images = LGListingImage.mapToFiles(imagesArray)

        media = (try keyedContainerBase.decodeIfPresent(FailableDecodableArray<LGMedia>.self, forKey: .media))?.validElements ?? []
        mediaThumbnail = try keyedContainerBase.decodeIfPresent(LGMediaThumbnail.self, forKey: .mediaThumbnail)

        user = try keyedContainerBase.decode(LGUserListing.self, forKey: .user)

        featured = try keyedContainerBase.decodeIfPresent(Bool.self, forKey: .featured)
        
        //  TODO: remove when fixed in backend. Video items should have an image.
        media = media.map { media in
            guard media.type == .video else { return media }
            let imageURL = imagesArray.first(where:  { $0.id == media.snapshotId })
            let outputs = LGMediaOutputs(image: imageURL?.url ?? imagesArray.first?.url, imageThumbnail: media.outputs.imageThumbnail,
                                         video: media.outputs.video, videoThumbnail: media.outputs.videoThumbnail)
            return LGMedia(objectId: nil, type: media.type, snapshotId: media.snapshotId, outputs: outputs)
        }

    }

    enum CodingKeysProductsApi: String, CodingKey {
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case nameAuto = "image_information"
        case priceFlag = "price_flag"
        case languageCode = "language_code"
        case categoryId = "category_id"
        case discardedReason = "rejected_reason"
    }
    
    enum CodingKeysVerticalsApi: String, CodingKey {
        case updatedAt = "updatedAt"
        case createdAt = "createdAt"
        case nameAuto = "imageInformation"
        case priceFlag = "priceFlag"
        case languageCode = "languageCode"
        case categoryId = "categoryId"
        case discardedReason = "rejectedReason"
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case name = "name"
        case descr = "description"
        case price = "price"
        case location = "geo"
        case status = "status"
        case thumbnail = "thumb"
        case images = "images"
        case media = "media"
        case mediaThumbnail = "media_thumb"
        case user = "owner"
        case featured = "featured"
        case currency = "currency"
    }

    enum LocationCodingKeysProductsApi: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
        case countryCode = "country_code"
        case city
        case zipCode = "zip_code"
    }
    
    enum LocationCodingKeysVerticalsApi: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
        case countryCode = "countryCode"
        case city
        case zipCode = "zipCode"
    }

    enum ThumbnailCodingKeys: String, CodingKey {
        case url
        case width
        case height
    }
}
