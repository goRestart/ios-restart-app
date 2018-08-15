//
//  LGRealEstate.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 12/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public protocol RealEstate: BaseListingModel {
    var realEstateAttributes: RealEstateAttributes { get }
}

struct LGRealEstate: RealEstate, Codable {
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
    let media: [Media]
    let mediaThumbnail: MediaThumbnail?
    var user: UserListing
    let featured: Bool?
    let realEstateAttributes: RealEstateAttributes
    
    init(realEstate: RealEstate) {
        self.init(objectId: realEstate.objectId,
                  updatedAt: realEstate.updatedAt,
                  createdAt: realEstate.createdAt,
                  name: realEstate.name,
                  nameAuto: realEstate.nameAuto,
                  descr: realEstate.descr,
                  price: realEstate.price,
                  currency: realEstate.currency,
                  location: realEstate.location,
                  postalAddress: realEstate.postalAddress,
                  languageCode: realEstate.languageCode,
                  category: realEstate.category,
                  status: realEstate.status,
                  thumbnail: realEstate.thumbnail,
                  thumbnailSize: realEstate.thumbnailSize,
                  images: realEstate.images,
                  media: realEstate.media,
                  mediaThumbnail: realEstate.mediaThumbnail,
                  user: realEstate.user,
                  featured: realEstate.featured,
                  realEstateAttributes: realEstate.realEstateAttributes)
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
         realEstateAttributes: RealEstateAttributes?) {
        
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
        self.realEstateAttributes = realEstateAttributes ?? RealEstateAttributes.emptyRealEstateAttributes()
    }
    
    init(product: Product) {
        self.init(objectId: product.objectId,
                  updatedAt: product.updatedAt,
                  createdAt: product.createdAt,
                  name: product.name,
                  nameAuto: product.nameAuto,
                  descr: product.descr,
                  price: product.price,
                  currency: product.currency,
                  location: product.location,
                  postalAddress: product.postalAddress,
                  languageCode: product.languageCode,
                  category: product.category,
                  status: product.status,
                  thumbnail: product.thumbnail,
                  thumbnailSize: product.thumbnailSize,
                  images: product.images,
                  media: product.media,
                  mediaThumbnail: product.mediaThumbnail,
                  user: product.user,
                  featured: product.featured,
                  realEstateAttributes: nil)
    }
    
    init(baseListing: BaseListingModel, attributes: RealEstateAttributes?) {
        self.init(objectId: baseListing.objectId,
                  updatedAt: baseListing.updatedAt,
                  createdAt: baseListing.createdAt,
                  name: baseListing.name,
                  nameAuto: baseListing.nameAuto,
                  descr: baseListing.descr,
                  price: baseListing.price,
                  currency: baseListing.currency,
                  location: baseListing.location,
                  postalAddress: baseListing.postalAddress,
                  languageCode: baseListing.languageCode,
                  category: baseListing.category,
                  status: baseListing.status,
                  thumbnail: baseListing.thumbnail,
                  thumbnailSize: baseListing.thumbnailSize,
                  images: baseListing.images,
                  media: baseListing.media,
                  mediaThumbnail: baseListing.mediaThumbnail,
                  user: baseListing.user,
                  featured: baseListing.featured,
                  realEstateAttributes: attributes)
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
                  realEstateAttributes: nil)
    }
    
    static func make(objectId: String?,
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
                     realEstateAttributes: RealEstateAttributes?) -> LGRealEstate {
        
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
                         media: [],
                         mediaThumbnail: nil,
                         user: user,
                         featured: featured,
                         realEstateAttributes: realEstateAttributes)
    }
    
    // MARK: Updates
    
    func updating(category: ListingCategory) -> LGRealEstate {
        return LGRealEstate(objectId: objectId,
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
                            realEstateAttributes: realEstateAttributes)
    }
    
    func updating(status: ListingStatus) -> LGRealEstate {
        return LGRealEstate(objectId: objectId,
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
                            realEstateAttributes: realEstateAttributes)
    }
    
    func updating(realEstateAttributes: RealEstateAttributes) -> LGRealEstate {
        return LGRealEstate(objectId: objectId,
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
                            realEstateAttributes: realEstateAttributes)
    }
    
    // MARK: Decodable
    
    /*
      {
      "id": "c204a867-1d92-467d-9ab6-5830ba358289",
      "name": "Clip on lamp",
      "categoryId": 10,
      "languageCode": "en_US",
      "description": "Lamp to light up your room",
      "price": 5,
      "currency": "USD",
      "status": 1,
      "geo": {
      "lat": 38.6858795,
      "lng": -77.3207672,
      "countryCode": "US",
      "city": "Lake Ridge",
      "zipCode": "22192"
      },
      "owner": {
        "id": "string",
        "name": "string",
        "avatarUrl": "string",
        "zipCode": "string",
        "countryCode": "string",
        "city": "string"
      },
      "images": [{
                 "url": "http://cdn.letgo.com/images/10/98/cf/16/1098cf160db986f4288d3b5f6c8b72bf.jpeg",
                 "id": "f6609638-cf73-4d34-9a8f-e4d11ec9ba81"
                 }, {
                 "url": "http://cdn.letgo.com/images/1d/b1/8e/42/1db18e42ed7219841f5a57bbda3c034a.jpeg",
                 "id": "e40b4110-0c26-4184-8a85-4ed755f2c4d1"
                 }, {
                 "url": "http://cdn.letgo.com/images/c6/b7/82/c8/c6b782c8f10603420fc4b808482549b7.jpeg",
                 "id": "90033803-fb11-4017-962a-b7bb6c809c80"
                 }],
      "thumb": {
      "url": "http://cdn.letgo.com/images/10/98/cf/16/1098cf160db986f4288d3b5f6c8b72bf_thumb.jpeg",
      "width": 720,
      "height": 1280
      },
      "createdAt": "2017-03-16T02:18:02+00:00",
      "updatedAt": "2017-03-29T14:07:36+00:00",
      "priceFlag": 2,
      "featured": false,
      "realEstateAttributes": {
      "typeOfProperty": "room",
      "typeOfListing": "rent",
      "numberOfBedrooms": 1,
      "numberOfBathrooms": 2
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

        let keyedContainer = try decoder.container(keyedBy: CodingKeysRealEstateAttributes.self)
        
        realEstateAttributes = (try keyedContainer.decodeIfPresent(RealEstateAttributes.self, forKey: .realEstateAttributes))
            ?? RealEstateAttributes.emptyRealEstateAttributes()
    }

    public func encode(to encoder: Encoder) throws {
        let baseListing = LGBaseListing(objectId: objectId,
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
                                        carAttributes: nil)
        // We don't sync real state attributes on purpose, we can sync them again later
        try baseListing.encode(to: encoder)
    }
    
    enum CodingKeysRealEstateAttributes: String, CodingKey {
        case realEstateAttributes = "realEstateAttributes"
    }
}

