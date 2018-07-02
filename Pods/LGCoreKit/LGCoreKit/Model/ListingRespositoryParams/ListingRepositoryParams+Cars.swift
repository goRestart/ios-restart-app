private enum CarAttributesCodingKey: String {
    case userType, makeId, modelId, minYear, maxYear, bodyType, fuelType, transmission,
        minMileage, maxMileage, mileageType, minSeats, maxSeats
    case driveTrain = "drivetrain"
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
        params[VerticalsParamsKeys.distanceType] = distanceType?.rawValue
        params[VerticalsParamsKeys.numResults] = numListings
        params[VerticalsParamsKeys.offset] = offset
        params[VerticalsParamsKeys.sort] = sortCriteria?.string
        params[VerticalsParamsKeys.since] = timeCriteria?.string
        
        // Cars attributes
        if let userTypes = userTypes, userTypes.hasOnlyOneCarSellerType, let apiValue = userTypes.first?.apiValue {
            params[CarAttributesCodingKey.userType.rawValue] = [apiValue]
        }
        params[CarAttributesCodingKey.makeId.rawValue] = makeId?.value
        params[CarAttributesCodingKey.modelId.rawValue] = modelId?.value
        params[CarAttributesCodingKey.minYear.rawValue] = startYear?.value
        params[CarAttributesCodingKey.maxYear.rawValue] = endYear?.value
        params[CarAttributesCodingKey.bodyType.rawValue] = bodyType?.map { $0.rawValue }
        params[CarAttributesCodingKey.driveTrain.rawValue] = drivetrain?.map { $0.rawValue }
        params[CarAttributesCodingKey.fuelType.rawValue] = fuelType?.map { $0.rawValue }
        params[CarAttributesCodingKey.transmission.rawValue] = transmision?.map { $0.rawValue }
        params[CarAttributesCodingKey.minSeats.rawValue] = startNumberOfSeats
        params[CarAttributesCodingKey.maxSeats.rawValue] = endNumberOfSeats
        params[CarAttributesCodingKey.minMileage.rawValue] = startMileage
        params[CarAttributesCodingKey.maxMileage.rawValue] = endMileage
        params[CarAttributesCodingKey.mileageType.rawValue] = mileageType
        
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
