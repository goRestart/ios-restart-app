//
//  ListingRepositoryParams.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 27/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

// MARK: - PARAMS

public struct RetrieveListingParam<T: Equatable> {
    public let value: T
    public let isNegated: Bool
    
    public init(value: T, isNegated: Bool) {
        self.value = value
        self.isNegated = isNegated
    }
}

public struct RetrieveListingParams {
    public var queryString: String?
    public var coordinates: LGLocationCoordinates2D?
    public var countryCode: String?
    public var categoryIds: [Int]?
    public var superKeywordIds: [Int]?
    public var sortCriteria: ListingSortCriteria?
    public var timeCriteria: ListingTimeCriteria?
    public var offset: Int?                 // skip results
    public var numListings: Int?            // number listings to return
    public var statuses: [ListingStatus]?   // Default 1,3
    public var maxPrice: Int?
    public var minPrice: Int?
    public var freePrice: Bool?
    public var distanceRadius: Int?
    public var distanceType: DistanceType?
    public var makeId: RetrieveListingParam<String>?
    public var modelId: RetrieveListingParam<String>?
    public var startYear: RetrieveListingParam<Int>?
    public var endYear: RetrieveListingParam<Int>?
    public var abtest: String?
    
    public init() { }
    
    var relatedProductsApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["num_results"] = numListings
        params["offset"] = offset
        return params
    }
    
    var userListingApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        
        params["num_results"] = numListings
        params["offset"] = offset
        params["country_code"] = countryCode

        if let statuses = statuses {
            if statuses.contains(.sold) || statuses.contains(.soldOld) {
                params["status"] = UserListingStatus.sold.rawValue
            } else {
                params["status"] = UserListingStatus.selling.rawValue
            }
        }
        return params
    }
    
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["search_term"] = queryString
        params["quadkey"] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        // In case country code is empty we send the request without it.
        if countryCode != "" {
            params["country_code"] = countryCode
        }
        let categories = categoryIds?.map { String($0) }.joined(separator: ",")
        if categories != "" {
            params["categories"] = categories
        }
        let superKeywords = superKeywordIds?.map { String($0) }.joined(separator: ",")
        if superKeywords != "" {
            params["keyword_category"] = superKeywords
        }
        if let freePrice = freePrice, freePrice {
            params["price_flag"] = ListingPriceFlag.free.rawValue
        }
        params["max_price"] = maxPrice
        params["min_price"] = minPrice
        params["distance_radius"] = distanceRadius
        params["distance_type"] = distanceType?.string
        params["num_results"] = numListings
        params["offset"] = offset
        params["sort"] = sortCriteria?.string
        params["since"] = timeCriteria?.string
        params["abtest"] = abtest
        
        // Car attributes
        var carsPositiveAttrs = [String: Any]()
        var carsNegativeAttrs = [String: Any]()
        
        if let makeId = makeId {
            let value = makeId.value
            if makeId.isNegated {
                carsNegativeAttrs["make"] = value
            } else {
                carsPositiveAttrs["make"] = value
            }
        }
        if let modelId = modelId {
            let value = modelId.value
            if modelId.isNegated {
                carsNegativeAttrs["model"] = value
            } else {
                carsPositiveAttrs["model"] = value
            }
        }
        if let startYear = startYear {
            let value = startYear.value
            if startYear.isNegated {
                carsNegativeAttrs["start_year"] = value
            } else {
                carsPositiveAttrs["start_year"] = value
            }
        }
        if let endYear = endYear {
            let value = endYear.value
            if endYear.isNegated {
                carsNegativeAttrs["end_year"] = value
            } else {
                carsPositiveAttrs["end_year"] = value
            }
        }
        
        if carsPositiveAttrs.keys.count > 0 {
            params["attributes"] = carsPositiveAttrs
        }
        if carsNegativeAttrs.keys.count > 0 {
            params["negative_attributes"] = carsNegativeAttrs
        }
        return params
    }
}

public struct IndexTrendingListingsParams {
    let countryCode: String?
    let coordinates: LGLocationCoordinates2D?
    let numListings: Int?            // number listings to return
    let offset: Int                  // skip results

    public init(countryCode: String?, coordinates: LGLocationCoordinates2D?, numProducts: Int? = nil, offset: Int = 0) {
        self.countryCode = countryCode
        self.coordinates = coordinates
        self.numListings = numProducts
        self.offset = offset
    }

    public func paramsWithOffset(_ offset: Int) -> IndexTrendingListingsParams {
        return IndexTrendingListingsParams(countryCode: countryCode, coordinates: coordinates,
                                           numProducts: numListings, offset: offset)
    }
    
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["quadkey"] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        params["country_code"] = countryCode
        params["num_results"] = numListings
        params["offset"] = offset
        return params
    }
}

public enum SoldIn: String {
    case letgo = "letgo"
    case external = "external"
    
    public static let allValues: [SoldIn] = [.letgo, .external]
}


public struct CreateTransactionParams {
    let listingId: String
    let buyerId: String?
    let soldIn: SoldIn?
    
    public init(listingId: String, buyerId: String?, soldIn: SoldIn?) {
        self.listingId = listingId
        self.buyerId = buyerId
        self.soldIn = soldIn
    }
    
    
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["productId"] = listingId
        params["buyerUserId"] = buyerId
        params["soldIn"] = soldIn?.rawValue
        return params
    }
}


// MARK: - ENUMS & STRUCTS

public enum ListingSortCriteria: Int, Equatable {
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

public enum ListingTimeCriteria: Int, Equatable {
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

public enum UserListingStatus: String {
    case selling = "selling"
    case sold = "sold"
}
