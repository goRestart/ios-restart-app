//
//  ListingCarParams.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 12/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//


private struct CarAttributesParamsKey {
    static let userType = "userType"
    static let makeId = "makeId"
    static let modelId = "modelId"
    static let minYear = "minYear"
    static let maxYear = "maxYear"
}

private struct CarSellerTypeParamsValue {
    static let user = "user"
    static let professional = "professional"
}

extension RetrieveListingParams {
    
    var carsApiParams: [String: Any] {
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
        params[VerticalsParamsKeys.distanceType] = distanceType?.string
        params[VerticalsParamsKeys.numResults] = numListings
        params[VerticalsParamsKeys.offset] = offset
        params[VerticalsParamsKeys.sort] = sortCriteria?.string
        params[VerticalsParamsKeys.since] = timeCriteria?.string
        
        // Cars attributes
        if let userTypes = userTypes, userTypes.hasOnlyOneCarSellerType, let apiValue = userTypes.first?.apiValue {
            params[CarAttributesParamsKey.userType] = [apiValue]
        }
        params[CarAttributesParamsKey.makeId] = makeId?.value
        params[CarAttributesParamsKey.modelId] = modelId?.value
        params[CarAttributesParamsKey.minYear] = startYear?.value
        params[CarAttributesParamsKey.maxYear] = endYear?.value
        
        return params
    }
}

extension UserType {
    var apiValue: String {
        switch self {
        case .user:
            return CarSellerTypeParamsValue.user
        case .pro:
            return CarSellerTypeParamsValue.professional
        case .dummy:
            return ""
        }
    }
}

private extension Array where Element == UserType {
    
    var containsBothNonDummyTypes: Bool {
        return contains(.pro) && contains(.user)
    }
    
    var hasOnlyOneCarSellerType: Bool {
        return !isEmpty && !containsBothNonDummyTypes
    }
}
