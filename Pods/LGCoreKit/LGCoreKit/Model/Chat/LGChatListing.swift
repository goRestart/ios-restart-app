//
//  LGChatListing.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ChatListing: BaseModel, Priceable {
    var name: String? { get }
    var status: ListingStatus { get }
    var image: File? { get }
    var price: ListingPrice { get }
    var currency: Currency { get }
    
    init(objectId: String?,
         name: String?,
         status: ListingStatus,
         image: File?,
         price: ListingPrice,
         currency: Currency)
}

extension ChatListing {
    func updating(listing: Listing) -> ChatListing {
        return type(of: self).init(objectId: listing.objectId,
                                   name: listing.name,
                                   status: listing.status,
                                   image: listing.images.first,
                                   price: listing.price,
                                   currency: listing.currency)
    }
    
    func updating(status: ListingStatus) -> ChatListing {
        return type(of: self).init(objectId: objectId,
                                   name: name,
                                   status: status,
                                   image: image,
                                   price: price,
                                   currency: currency)
    }
}

struct LGChatListing: ChatListing, Decodable {

    private static let emptyListingId = "00000000-0000-0000-0000-000000000000" // empty product id, to keep retrocompatibility with old app versions

    let objectId: String?
    let name: String?
    let status: ListingStatus
    let image: File?
    let price: ListingPrice
    let currency: Currency
    
    init(objectId: String?,
         name: String?,
         status: ListingStatus,
         image: File?,
         price: Double?,
         priceFlag: ListingPriceFlag?,
         currency: Currency) {
        self.objectId = objectId
        self.name = name
        self.status = status
        self.image = image
        self.price = ListingPrice.fromPrice(price, andFlag: priceFlag)
        self.currency = currency
    }
    
    init(objectId: String?,
         name: String?,
         status: ListingStatus,
         image: File?,
         price: ListingPrice,
         currency: Currency) {
        self.objectId = objectId
        self.name = name
        self.status = status
        self.image = image
        self.price = price
        self.currency = currency
    }
    
    fileprivate static func make(objectId: String?,
                                 name: String?,
                                 status: ListingStatus,
                                 image: LGFile?,
                                 price: Double?,
                                 priceFlag: ListingPriceFlag?,
                                 currency: Currency) -> LGChatListing {
        return LGChatListing(objectId: objectId,
                             name: name,
                             status: status,
                             image: image,
                             price: price,
                             priceFlag: priceFlag,
                             currency: currency)
    }
    
    // MARK: Decodable
    
    /*
     {
     "id": [uuid|objectId],
     "name": [string|null],
     "status": [int],
     "image": [url],
     "price": {
     "amount": [float],
     "currency": [string],
     "flag": [int]
     }
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let objectIdValue = try keyedContainer.decode(String.self, forKey: .objectId)
        objectId = objectIdValue == LGChatListing.emptyListingId ? nil : objectIdValue
        name = try keyedContainer.decodeIfPresent(String.self, forKey: .name)
        let code = try keyedContainer.decode(Int.self, forKey: .status)
        let statusCode = ListingStatusCode(rawValue: code) ?? .approved
        status = ListingStatus(statusCode: statusCode) ?? .pending
        if let avatarStringURL = try? keyedContainer.decode(String.self, forKey: .image) {
            image = LGFile(id: nil, urlString: avatarStringURL)
        } else {
            image = nil
        }
        let priceDecoded = try keyedContainer.decode(ListingPriceDecodable.self, forKey: .price)
        currency = Currency.currencyWithCode(priceDecoded.currency)
        price = ListingPrice.fromPrice(priceDecoded.amount, andFlag: priceDecoded.flag)
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case name
        case status
        case image
        case price
    }
}
