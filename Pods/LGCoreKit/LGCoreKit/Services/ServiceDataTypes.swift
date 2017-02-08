//
//  ServiceDataTypes.swift
//  LGCoreKit
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

// MARK: - COMPLETION CLOSURES

public typealias RetrieveProductCompletion = (_ product: Product?, _ error: Error?) -> Void
public typealias RetrieveProductsCompletion = (_ products: Array<Any>?, _ lastPage: Bool?, _ error: Error?) -> Void

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
    public var freePrice: Bool?
    public var distanceRadius: Int?
    public var distanceType: DistanceType?

    public init() {

    }

    public var description: String { return "queryString: \(queryString); latitude: \(coordinates?.latitude); longitude: \(coordinates?.longitude); countryCode: \(countryCode); categoryIds: \(categoryIds); sortCriteria: \(sortCriteria); timeCriteria: \(timeCriteria); offset: \(offset); numProducts: \(numProducts); statuses: \(statuses); maxPrice: \(maxPrice); minPrice: \(minPrice); distanceRadius: \(distanceRadius); distanceType: \(distanceType)" }
}

public func ==(lhs: RetrieveProductsParams, rhs: RetrieveProductsParams) -> Bool {
    return lhs.queryString == rhs.queryString && lhs.coordinates == rhs.coordinates &&
        lhs.countryCode == rhs.countryCode && lhs.categoryIds == rhs.categoryIds &&
        lhs.sortCriteria == rhs.sortCriteria && lhs.timeCriteria == rhs.timeCriteria &&
        lhs.offset == rhs.offset && lhs.numProducts == rhs.numProducts &&
        lhs.statuses == rhs.statuses && lhs.maxPrice == rhs.maxPrice &&
        lhs.minPrice == rhs.minPrice && lhs.distanceRadius == rhs.distanceRadius &&
        lhs.distanceType == rhs.distanceType
}

public struct IndexTrendingProductsParams {
    let countryCode: String?
    let coordinates: LGLocationCoordinates2D?
    let numProducts: Int?            // number products to return
    let offset: Int                  // skip results

    public init(countryCode: String?, coordinates: LGLocationCoordinates2D?, numProducts: Int? = nil, offset: Int = 0) {
        self.countryCode = countryCode
        self.coordinates = coordinates
        self.numProducts = numProducts
        self.offset = offset
    }

    public func paramsWithOffset(_ offset: Int) -> IndexTrendingProductsParams {
        return IndexTrendingProductsParams(countryCode: countryCode, coordinates: coordinates,
                                           numProducts: numProducts, offset: offset)
    }
}

extension IndexTrendingProductsParams {
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["quadkey"] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        params["country_code"] = countryCode 
        params["num_results"] = numProducts 
        params["offset"] = offset 
        return params
    }
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

public struct ReportUserParams {
    public var reason: ReportUserReason
    public var comment: String?

    public init(reason: ReportUserReason, comment: String?){
        self.reason = reason
        self.comment = comment
    }
}


// MARK: - ENUMS & STRUCTS

public enum ProductSortCriteria: Int, Equatable {
    case distance = 1, priceAsc = 2, priceDesc = 3, creation = 4
    var string: String? {
        get {
            switch self {
            case .distance:
                return "distance"
            case .priceAsc:
                return "price_asc"
            case .priceDesc:
                return "price_desc"
            case .creation:
                return "recent"
            }
        }
    }
}

public enum ProductTimeCriteria: Int, Equatable {
    case day = 1, week = 2, month = 3, all = 4
    var string : String? {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .all:
            return nil
        }
    }
}

public enum UserProductStatus: String {
    case selling = "selling"
    case sold = "sold"
}

public enum ReportUserReason: Int, Equatable {
    case offensive = 1, scammer = 2, mia = 3, suspicious = 4, inactive = 5, prohibitedItems = 6, spammer = 7,
    counterfeitItems = 8, others = 9
}


// MARK: - Extensions

extension RetrieveProductsParams {
    
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["search_term"] = queryString
        params["quadkey"] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        if countryCode != "" {
            params["country_code"] = countryCode
        }
        let categories = categoryIds?.map { String($0) }.joined(separator: ",")
        if categories != "" {
            params["categories"] = categories
        }
        if let freePrice = freePrice, freePrice {
            params["price_flag"] = ProductPriceFlag.free.rawValue
        }
        params["max_price"] = maxPrice
        params["min_price"] = minPrice
        params["distance_radius"] = distanceRadius
        params["distance_type"] = distanceType?.string
        params["num_results"] = numProducts
        params["offset"] = offset
        params["sort"] = sortCriteria?.string
        params["since"] = timeCriteria?.string
        
        return params
    }
}

extension RetrieveProductsParams {
    var userProductApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        
        params["num_results"] = numProducts
        params["offset"] = offset
        params["country_code"] = countryCode

        // TODO: Think twice about this :-P
        if self.statuses == [.sold, .soldOld] {
            params["status"] = UserProductStatus.sold.rawValue
        } else {
            params["status"] = UserProductStatus.selling.rawValue
        }
        
        return params
    }
}

extension RetrieveProductsParams {
    var relatedProductsApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["num_results"] = numProducts
        params["offset"] = offset
        return params
    }
}

extension ReportUserParams {
    var reportUserApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()

        params["reason_id"] = reason.rawValue
        params["comment"] = comment

        return params
    }
}
