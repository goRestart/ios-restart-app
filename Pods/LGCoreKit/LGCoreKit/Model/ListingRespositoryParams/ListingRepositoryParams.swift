
struct ApiProductsParamsKeys {
    static let numberOfResults = "num_results"
    static let offset = "offset"
    static let countryCode = "country_code"
    static let status = "status"
    static let searchTerm = "search_term"
    static let quadkey = "quadkey"
    static let categories = "categories"
    static let keywordCategory = "keyword_category"
    static let priceFlag = "price_flag"
    static let maxPrice = "max_price"
    static let minPrice = "min_price"
    static let distanceRadius = "distance_radius"
    static let distanceType = "distance_type"
    static let sort = "sort"
    static let since = "since"
    static let abtest = "abtest"
    static let make = "make"
    static let model = "model"
    static let startYear = "start_year"
    static let endYear = "end_year"
    static let attributes = "attributes"
}

struct DiscoveryParamsKeys {
    static let customFeedVariant = "variant"
}

struct VerticalsParamsKeys {
    static let searchTerm = "searchTerm"
    static let quadkey = "quadkey"
    static let countryCode = "countryCode"
    static let priceFlag = "priceFlag"
    static let maxPrice = "maxPrice"
    static let minPrice = "minPrice"
    static let distanceRadius = "distanceRadius"
    static let distanceType = "distanceType"
    static let numResults = "numResults"
    static let offset = "offset"
    static let sort = "sort"
    static let since = "since"
}

struct RealEstateParamsKeys {
    static let typeOfProperty = "typeOfProperty"
    static let typeOfListing = "typeOfListing"
    static let numberOfBedrooms = "numberOfBedrooms"
    static let numberOfBathrooms = "numberOfBathrooms"
    static let numberOfLivingRooms = "numberOfLivingRooms"
    static let sizeSquareMetersFrom = "sizeSquareMetersFrom"
    static let sizeSquareMetersTo = "sizeSquareMetersTo"
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
    public var statuses: [ListingStatusCode]?   // Default 1,3
    public var maxPrice: Int?
    public var minPrice: Int?
    public var freePrice: Bool?
    public var distanceRadius: Int?
    public var distanceType: DistanceType?
    public var abtest: String?
    public var relaxParam: RelaxParam?
    public var similarParam: SimilarParam?
    
    
    //  MARK: Discovery
    
    public var customFeedVariant: Int?
    
    
    //  MARK: Car
    public var userTypes: [UserType]?
    public var makeId: String?
    public var modelId: String?
    public var startYear: Int?
    public var endYear: Int?
    public var bodyType: [CarBodyType]?
    public var drivetrain: [CarDriveTrainType]?
    public var fuelType: [CarFuelType]?
    public var transmision: [CarTransmissionType]?
    public var startMileage: Int?
    public var endMileage: Int?
    public var mileageType: String?
    public var startNumberOfSeats: Int?
    public var endNumberOfSeats: Int?
    
    //  MARK: Services
    public var typeIds: [String]?
    public var subtypeIds: [String]?
    
    //  MARK: Real Estate
    public var propertyType: String?
    public var offerType: [String]?
    public var numberOfBedrooms: Int?
    public var numberOfBathrooms: Float?
    public var numberOfLivingRooms: Int?
    public var sizeSquareMetersFrom: Int?
    public var sizeSquareMetersTo: Int?
    
    public init() { }
    
    var relatedProductsApiParams: [String: Any] {
        var params = [String: Any]()
        params[ApiProductsParamsKeys.numberOfResults] = numListings
        params[ApiProductsParamsKeys.offset] = offset
        return params
    }
    
    var userListingApiParams: [String: Any] {
        var params = [String: Any]()
        
        params[ApiProductsParamsKeys.numberOfResults] = numListings
        params[ApiProductsParamsKeys.offset] = offset
        params[ApiProductsParamsKeys.countryCode] = countryCode

        if let statuses = statuses {
            var statusValue = ""
            if statuses.contains(.sold) || statuses.contains(.soldOld) {
                statusValue = UserListingStatus.sold.rawValue
            } else {
                statusValue = UserListingStatus.selling.rawValue
            }
            if statuses.contains(.discarded) {
                statusValue.append(",\(UserListingStatus.discarded)")
            }
            params[ApiProductsParamsKeys.status] = statusValue
        }
        
        return params
    }
    
    var realEstateApiParams: [String: Any] {
        var params = [String: Any]()
        params[VerticalsParamsKeys.searchTerm] = queryString
        params[VerticalsParamsKeys.quadkey] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        // In case country code is empty we send the request without it.
        if let countryCode = countryCode, !countryCode.isEmpty {
            params[VerticalsParamsKeys.countryCode] = countryCode
        }
        if let freePrice = freePrice, freePrice {
            params[VerticalsParamsKeys.priceFlag] = ListingPriceFlag.free.rawValue
        }
        params[VerticalsParamsKeys.maxPrice] = maxPrice
        params[VerticalsParamsKeys.minPrice] = minPrice
        params[VerticalsParamsKeys.distanceRadius] = distanceRadius
        params[VerticalsParamsKeys.distanceType] = distanceType?.rawValue
        params[VerticalsParamsKeys.numResults] = numListings
        params[VerticalsParamsKeys.offset] = offset
        params[VerticalsParamsKeys.sort] = sortCriteria?.string
        params[VerticalsParamsKeys.since] = timeCriteria?.parameterValue
        
        // Real Estate attributes
        if let propertyType = propertyType {
            params[RealEstateParamsKeys.typeOfProperty] = [propertyType]
        }
        if let offerType = offerType {
            params[RealEstateParamsKeys.typeOfListing] = offerType
        }
        params[RealEstateParamsKeys.numberOfBedrooms] = numberOfBedrooms
        params[RealEstateParamsKeys.numberOfBathrooms] = numberOfBathrooms
        params[RealEstateParamsKeys.numberOfLivingRooms] = numberOfLivingRooms
        params[RealEstateParamsKeys.sizeSquareMetersFrom] = sizeSquareMetersFrom
        params[RealEstateParamsKeys.sizeSquareMetersTo] = sizeSquareMetersTo
       
        return params
    }
    
    var customFeedApiParams: [String: Any] {
        var params = [String: Any]()
        if let countryCode = countryCode, !countryCode.isEmpty {
            params[ApiProductsParamsKeys.countryCode] = countryCode
        }
        params[ApiProductsParamsKeys.quadkey] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        params[ApiProductsParamsKeys.offset] = offset
        params[ApiProductsParamsKeys.numberOfResults] = numListings
        params[DiscoveryParamsKeys.customFeedVariant] = customFeedVariant
        return params
    }
    
    var letgoApiParams: [String: Any] {
        var params = [String: Any]()
        params[ApiProductsParamsKeys.searchTerm] = queryString
        params[ApiProductsParamsKeys.quadkey] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        // In case country code is empty we send the request without it.
        if let countryCode = countryCode, !countryCode.isEmpty {
            params[ApiProductsParamsKeys.countryCode] = countryCode
        }
        let categories = categoryIds?.map { String($0) }.joined(separator: ",")
        if categories != "" {
            params[ApiProductsParamsKeys.categories] = categories
        }
        let superKeywords = superKeywordIds?.map { String($0) }.joined(separator: ",")
        if superKeywords != "" {
            params[ApiProductsParamsKeys.keywordCategory] = superKeywords
        }
        if let freePrice = freePrice, freePrice {
            params[ApiProductsParamsKeys.priceFlag] = ListingPriceFlag.free.rawValue
        }
        params[ApiProductsParamsKeys.maxPrice] = maxPrice
        params[ApiProductsParamsKeys.minPrice] = minPrice
        params[ApiProductsParamsKeys.distanceRadius] = distanceRadius
        params[ApiProductsParamsKeys.distanceType] = distanceType?.rawValue
        params[ApiProductsParamsKeys.numberOfResults] = numListings
        params[ApiProductsParamsKeys.offset] = offset
        params[ApiProductsParamsKeys.sort] = sortCriteria?.string
        params[ApiProductsParamsKeys.since] = timeCriteria?.parameterValue
        params[ApiProductsParamsKeys.abtest] = abtest
        
        // Car attributes
        var carAttributes = [String: Any]()
        
        if let makeId = makeId {
            carAttributes[ApiProductsParamsKeys.make] = makeId
        }
        if let modelId = modelId {
            carAttributes[ApiProductsParamsKeys.model] = modelId
        }
        if let startYear = startYear {
            carAttributes[ApiProductsParamsKeys.startYear] = startYear
        }
        if let endYear = endYear {
            carAttributes[ApiProductsParamsKeys.endYear] = endYear
        }
        
        if carAttributes.keys.count > 0 {
            params[ApiProductsParamsKeys.attributes] = carAttributes
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
    
    var letgoApiParams: [String: Any] {
        var params = [String: Any]()
        params[ApiProductsParamsKeys.quadkey] = coordinates?.coordsToQuadKey(LGCoreKit.quadKeyZoomLevel)
        params[ApiProductsParamsKeys.countryCode] = countryCode
        params[ApiProductsParamsKeys.numberOfResults] = numListings
        params[ApiProductsParamsKeys.offset] = offset
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

public enum ListingTimeCriteria: Equatable {
    case day
    case week
    case month
    case all
    case date(date: Date)
    
    private static let dateFormatter = LGDateFormatter()
    
    var parameterValue: String? {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .all:
            return nil
        case .date(let date):
            return ListingTimeCriteria.dateFormatter.string(from: date)
        }
    }
}

public enum UserListingStatus: String {
    case selling = "selling"
    case sold = "sold"
    case discarded = "discarded"
}
