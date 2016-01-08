//
//  ServiceDataTypes.swift
//  LGCoreKit
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

// MARK: - COMPLETION CLOSURES

public typealias RetrieveProductCompletion = (product: Product?, error: NSError?) -> Void
public typealias RetrieveProductsCompletion = (products: NSArray?, lastPage: Bool?, error: NSError?) -> Void

// MARK: - PARAMS

public struct RetrieveTokenParams {
    private(set) var clientId: String
    private(set) var clientSecret: String
    public init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
}

public struct RetrieveProductParams: CustomStringConvertible, Equatable {
    public var objectId: String
    public init(objectId: String) {
        self.objectId = objectId
    }

    public var description: String { return "objectId: \(objectId)" }
}

public func ==(lhs: RetrieveProductParams, rhs: RetrieveProductParams) -> Bool {
    return lhs.objectId == rhs.objectId
}

public struct RetrieveProductsParams: CustomStringConvertible, Equatable {
    public var queryString: String?
    public var coordinates: LGLocationCoordinates2D?
    public var countryCode: String?
    public var categoryIds: [Int]?
    public var sortCriteria: ProductSortCriteria?
    public var timeCriteria: ProductTimeCriteria?
    public var offset: Int?                 // skip results
    public var numProducts: Int?            // number products to return
    public var statuses: [ProductStatus]?   // Default 1,3
    public var maxPrice: Int?
    public var minPrice: Int?
    public var distanceRadius: Int?
    public var distanceType: DistanceType?
    public var userObjectId: String?

    public init() {

    }

    public var description: String { return "queryString: \(queryString); latitude: \(coordinates?.latitude); longitude: \(coordinates?.longitude); countryCode: \(countryCode); categoryIds: \(categoryIds); sortCriteria: \(sortCriteria); timeCriteria: \(timeCriteria); offset: \(offset); numProducts: \(numProducts); statuses: \(statuses); maxPrice: \(maxPrice); minPrice: \(minPrice); distanceRadius: \(distanceRadius); distanceType: \(distanceType); userObjectId: \(userObjectId)" }
}

public func ==(lhs: RetrieveProductsParams, rhs: RetrieveProductsParams) -> Bool {
    return lhs.queryString == rhs.queryString && lhs.coordinates == rhs.coordinates &&
        lhs.countryCode == rhs.countryCode && lhs.categoryIds == rhs.categoryIds &&
        lhs.sortCriteria == rhs.sortCriteria && lhs.timeCriteria == rhs.timeCriteria &&
        lhs.offset == rhs.offset && lhs.numProducts == rhs.numProducts &&
        lhs.statuses == rhs.statuses && lhs.maxPrice == rhs.maxPrice &&
        lhs.minPrice == rhs.minPrice && lhs.distanceRadius == rhs.distanceRadius &&
        lhs.distanceType == rhs.distanceType && lhs.userObjectId == rhs.userObjectId
}

public struct SaveProductParams: CustomStringConvertible, Equatable {

    public var name: String?
    public var category: String?
    public var languageCode: String?
    public var userId: String?
    public var descr: String?
    public var price: String?
    public var currency: String?
    public var latitude: String?
    public var longitude: String?
    public var countryCode: String?
    public var city: String?
    public var address: String?
    public var zipCode: String?
    public var images: [String]?

    public init() {

    }

    public var description: String { return "name: \(name); category: \(category); languageCode: \(languageCode); userId: \(userId); descr: \(descr); price: \(price); currency: \(currency); latitude: \(latitude); longitude: \(longitude); countryCode: \(countryCode); city: \(city); address: \(address); zipCode: \(zipCode); images: \(images)" }
}

public func ==(lhs: SaveProductParams, rhs: SaveProductParams) -> Bool {

    return lhs.name == rhs.name && lhs.category == rhs.category &&
        lhs.languageCode == rhs.languageCode && lhs.userId == rhs.userId &&
        lhs.price == rhs.price && lhs.currency == rhs.currency &&
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude &&
        lhs.countryCode == rhs.countryCode && lhs.city == rhs.city &&
        lhs.address == rhs.address && lhs.zipCode == rhs.zipCode &&
        lhs.images == rhs.images && lhs.descr == rhs.descr
}


// MARK: - ENUMS & STRUCTS

public enum ProductSortCriteria: Int, Equatable {
    case Distance = 1, PriceAsc = 2, PriceDesc = 3, Creation = 4
    var string: String? {
        get {
            switch self {
            case .Distance:
                return nil
            case .PriceAsc:
                return "price_asc"
            case .PriceDesc:
                return "price_desc"
            case .Creation:
                return "recent"
            }
        }
    }
}

public enum ProductTimeCriteria: Int, Equatable {
    case Day = 1, Week = 2, Month = 3, All = 4
    var string : String? {
        switch self {
        case .Day:
            return "day"
        case .Week:
            return "week"
        case .Month:
            return "month"
        case .All:
            return nil
        }
    }
}

public enum UserProductStatus: String {
    case Selling = "selling"
    case Sold = "sold"
}
