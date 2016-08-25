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

    public func paramsWithOffset(offset: Int) -> IndexTrendingProductsParams {
        return IndexTrendingProductsParams(countryCode: countryCode, coordinates: coordinates,
                                           numProducts: numProducts, offset: offset)
    }
}

extension IndexTrendingProductsParams {
    var letgoApiParams: Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>()
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
    case Distance = 1, PriceAsc = 2, PriceDesc = 3, Creation = 4
    var string: String? {
        get {
            switch self {
            case .Distance:
                return "distance"
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

public enum ReportUserReason: Int, Equatable {
    case Offensive = 1, Scammer = 2, Mia = 3, Suspicious = 4, Inactive = 5, ProhibitedItems = 6, Spammer = 7,
    CounterfeitItems = 8, Others = 9
}


// MARK: - Extensions

extension RetrieveProductsParams {
    
    var letgoApiParams: Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>()
        params["search_term"] = queryString
        params["quadkey"] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        params["country_code"] = countryCode
        let categories = categoryIds?.map { String($0) }.joinWithSeparator(",")
        if categories != "" {
            params["categories"] = categories
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
    var userProductApiParams: Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>()
        
        params["num_results"] = numProducts
        params["offset"] = offset
        
        // TODO: Think twice about this :-P
        if self.statuses == [.Sold, .SoldOld] {
            params["status"] = UserProductStatus.Sold.rawValue
        } else {
            params["status"] = UserProductStatus.Selling.rawValue
        }
        
        return params
    }
}

extension RetrieveProductsParams {
    var relatedProductsApiParams: Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>()
        params["num_results"] = numProducts
        params["offset"] = offset
        return params
    }
}

extension ReportUserParams {
    var reportUserApiParams: Dictionary<String, AnyObject> {
        var params = Dictionary<String, AnyObject>()

        params["reason_id"] = reason.rawValue
        params["comment"] = comment

        return params
    }
}
