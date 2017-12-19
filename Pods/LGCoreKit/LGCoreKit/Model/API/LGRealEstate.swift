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

struct LGRealEstate: RealEstate, Decodable {
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
        self.user = user
        self.featured = featured ?? false
        self.realEstateAttributes = realEstateAttributes ?? RealEstateAttributes.emptyRealEstateAttributes()
    }
    
    init(chatListing: ChatListing, chatInterlocutor: ChatInterlocutor) {
        let user = LGUserListing(chatInterlocutor: chatInterlocutor)
        let images = [chatListing.image].flatMap{$0}
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
                     status: Int,
                     thumbnail: String?,
                     thumbnailSize: LGSize?,
                     images: [LGFile],
                     user: LGUserListing,
                     featured: Bool?,
                     realEstateAttributes: RealEstateAttributes?) -> LGRealEstate {
        
        let actualCurrency = Currency.currencyWithCode(currency)
        let actualCategory = ListingCategory(rawValue: category) ?? .other
        let actualStatus = ListingStatus(rawValue: status) ?? .pending
        let actualThumbnail = LGFile(id: nil, urlString: thumbnail)
        let actualImages = images.flatMap { $0 as File }
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
                         status: actualStatus,
                         thumbnail: actualThumbnail,
                         thumbnailSize: thumbnailSize,
                         images: actualImages,
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
                            user: user,
                            featured: featured,
                            realEstateAttributes: realEstateAttributes)
    }
    
    // MARK: Decodable
    
    /*
     {
     "id": "string",
     "name": "string",
     "categoryId": 10,
     "languageCode": "string",
     "description": "string",
     "price": 1.75,
     "currency": "USD|EUR",
     "priceFlag": "0(normal)|1(free)|2(negotiable)|3(firm)",
     "status": 0,
     "realEstateAttributes": {
     "typeOfProperty": "apartment|house|room|commercial|others",
     "typeOfListing": "rent|sell",
     "numberOfBedrooms": 1,
     "numberOfBathrooms": 1.5
     },
     "geo": {
     "lat": 41.54061842,
     "lng": 2.43402958,
     "countryCode": "string",
     "city": "string",
     "zipCode": "string"
     },
     "owner": {
     "id": "string"
     },
     "images": [
     {
     "id": "string",
     "url": "string"
     }
     ],
     "thumb": {
     "url": "string",
     "width": 200,
     "height": 200
     },
     "createdAt": "string",
     "updatedAt": "string",
     "featured": true
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
        nameAuto = nil
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
        
        let postalAddressKeyedContainer = try keyedContainer.nestedContainer(keyedBy: PostalAddressCodingKeys.self,
                                                                        forKey: .location)
        postalAddress = PostalAddress(address: try postalAddressKeyedContainer.decodeIfPresent(String.self, forKey: .address),
                                      city: try postalAddressKeyedContainer.decodeIfPresent(String.self, forKey: .city),
                                      zipCode: try postalAddressKeyedContainer.decodeIfPresent(String.self, forKey: .zipCode),
                                      state: try postalAddressKeyedContainer.decodeIfPresent(String.self, forKey: .state),
                                      countryCode: try postalAddressKeyedContainer.decodeIfPresent(String.self, forKey: .countryCode),
                                      country: try postalAddressKeyedContainer.decodeIfPresent(String.self, forKey: .country))
        
        languageCode = try keyedContainer.decodeIfPresent(String.self, forKey: .languageCode)
        let categoryRawValue = try keyedContainer.decode(Int.self, forKey: .categoryId)
        category = ListingCategory(rawValue: categoryRawValue) ?? .realEstate
        
        let statusRawValue = try keyedContainer.decode(Int.self, forKey: .status)
        status = ListingStatus(rawValue: statusRawValue) ?? .pending
        
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
        
        realEstateAttributes = (try keyedContainer.decodeIfPresent(RealEstateAttributes.self, forKey: .realEstateAttributes))
            ?? RealEstateAttributes.emptyRealEstateAttributes()
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case updatedAt = "updatedAt"
        case createdAt = "createdAt"
        case name = "name"
        case descr = "description"
        case price = "price"
        case priceFlag = "priceFlag"
        case currency = "currency"
        case location = "geo"
        case languageCode = "languageCode"
        case categoryId = "categoryId"
        case status = "status"
        case thumbnail = "thumb"
        case images = "images"
        case user = "owner"
        case featured = "featured"
        case realEstateAttributes = "realEstateAttributes"
    }
    
    enum LocationCodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
        case countryCode = "countryCode"
        case city
        case zipCode = "zipCode"
    }
    
    enum PostalAddressCodingKeys: String, CodingKey {
        case address = "address"
        case city = "city"
        case zipCode = "zipCode"
        case state = "state"
        case countryCode = "countryCode"
        case country = "country"
    }
    
    enum ThumbnailCodingKeys: String, CodingKey {
        case url
        case width
        case height
    }
}
