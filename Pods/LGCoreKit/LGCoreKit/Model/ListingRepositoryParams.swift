//
//  ListingRepositoryParams.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 27/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

// MARK: - PARAMS

public struct RetrieveListingParams: CustomStringConvertible, Equatable {
    public var queryString: String?
    public var coordinates: LGLocationCoordinates2D?
    public var countryCode: String?
    public var categoryIds: [Int]?
    public var sortCriteria: ProductSortCriteria?
    public var timeCriteria: ProductTimeCriteria?
    public var offset: Int?                 // skip results
    public var numProducts: Int?            // number products to return
    public var statuses: [ListingStatus]?   // Default 1,3
    public var maxPrice: Int?
    public var minPrice: Int?
    public var freePrice: Bool?
    public var distanceRadius: Int?
    public var distanceType: DistanceType?

    public init() {

    }

    public var description: String { return "queryString: \(queryString); latitude: \(coordinates?.latitude); longitude: \(coordinates?.longitude); countryCode: \(countryCode); categoryIds: \(categoryIds); sortCriteria: \(sortCriteria); timeCriteria: \(timeCriteria); offset: \(offset); numProducts: \(numProducts); statuses: \(statuses); maxPrice: \(maxPrice); minPrice: \(minPrice); distanceRadius: \(distanceRadius); distanceType: \(distanceType)" }
}

public func ==(lhs: RetrieveListingParams, rhs: RetrieveListingParams) -> Bool {
    return lhs.queryString == rhs.queryString && lhs.coordinates == rhs.coordinates &&
        lhs.countryCode == rhs.countryCode && lhs.categoryIds == rhs.categoryIds &&
        lhs.sortCriteria == rhs.sortCriteria && lhs.timeCriteria == rhs.timeCriteria &&
        lhs.offset == rhs.offset && lhs.numProducts == rhs.numProducts &&
        lhs.statuses == rhs.statuses && lhs.maxPrice == rhs.maxPrice &&
        lhs.minPrice == rhs.minPrice && lhs.distanceRadius == rhs.distanceRadius &&
        lhs.distanceType == rhs.distanceType
}

public struct IndexTrendingListingsParams {
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

    public func paramsWithOffset(_ offset: Int) -> IndexTrendingListingsParams {
        return IndexTrendingListingsParams(countryCode: countryCode, coordinates: coordinates,
                                           numProducts: numProducts, offset: offset)
    }
}

extension IndexTrendingListingsParams {
    var letgoApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["quadkey"] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        params["country_code"] = countryCode
        params["num_results"] = numProducts
        params["offset"] = offset
        return params
    }
}

public class ProductEditionParams: ProductCreationParams {
    let productId: String
    let userId: String

    public convenience init?(product: Product) {
        guard let productId = product.objectId, let userId = product.user.objectId else { return nil }
        self.init(product: product, productId: productId, userId: userId)
    }

    init(product: Product, productId: String, userId: String) {
        self.productId = productId
        self.userId = userId
        super.init(name: product.name,
                   description: product.descr,
                   price: product.price,
                   category: product.category,
                   currency: product.currency,
                   location: product.location,
                   postalAddress: product.postalAddress,
                   images: product.images)
        if let languageCode = product.languageCode {
            self.languageCode = languageCode
        }
    }

    func apiEncode() -> [String: Any] {
        return super.apiEncode(userId: userId)
    }

    public static func ==(lhs: ProductEditionParams, rhs: ProductEditionParams) -> Bool {
        return lhs.productId == rhs.productId && ((lhs as ProductCreationParams) == (rhs as ProductCreationParams))
    }
}

public class ProductCreationParams: CustomStringConvertible, Equatable {

    public var name: String?
    public var descr: String?
    public var price: ListingPrice
    public var category: ListingCategory
    public var currency: Currency
    public var location: LGLocationCoordinates2D
    public var postalAddress: PostalAddress
    public var images: [File]
    var languageCode: String

    public init(name: String?, description: String?, price: ListingPrice, category: ListingCategory,
         currency: Currency, location: LGLocationCoordinates2D, postalAddress: PostalAddress, images: [File]) {
        self.name = name
        self.descr = description
        self.price = price
        self.category = category
        self.currency = currency
        self.location = location
        self.postalAddress = postalAddress
        // TODO: inject locale
        self.languageCode = Locale.current.identifier
        self.images = images
    }

    public var description: String { return "name: \(name); category: \(category.rawValue); coordinates: \(location); postalAddress: \(postalAddress); description: \(descr); price: \(price.value); currency: \(currency.code); images: \(images.flatMap { $0.fileURL })" }

    public static func ==(lhs: ProductCreationParams, rhs: ProductCreationParams) -> Bool {
        return lhs.name == rhs.name && lhs.category == rhs.category &&
            lhs.price == rhs.price && lhs.currency == rhs.currency &&
            lhs.location == rhs.location && lhs.postalAddress == rhs.postalAddress &&
            lhs.descr == rhs.descr
    }

    func apiEncode(userId: String) -> [String: Any] {
        var params: [String: Any] = [:]
        params["name"] = name
        params["category"] = category.rawValue
        params["languageCode"] = languageCode
        params["userId"] = userId
        params["description"] = descr
        params["price"] = price.value
        params["price_flag"] = price.priceFlag.rawValue
        params["currency"] = currency.code
        params["latitude"] = location.latitude
        params["longitude"] = location.longitude
        params["countryCode"] = postalAddress.countryCode
        params["city"] = postalAddress.city
        params["address"] = postalAddress.address
        params["zipCode"] = postalAddress.zipCode

        let tokensString = images.flatMap{$0.objectId}.map{"\"" + $0 + "\""}.joined(separator: ",")
        params["images"] = "[" + tokensString + "]"

        return params
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




// MARK: - Extensions

extension RetrieveListingParams {

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
        if let freePrice = freePrice, freePrice {
            params["price_flag"] = ListingPriceFlag.free.rawValue
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

extension RetrieveListingParams {
    var userListingApiParams: Dictionary<String, Any> {
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

extension RetrieveListingParams {
    var relatedProductsApiParams: Dictionary<String, Any> {
        var params = Dictionary<String, Any>()
        params["num_results"] = numProducts
        params["offset"] = offset
        return params
    }
}
