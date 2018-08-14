//  Copyright © 2018 Ambatana Inc. All rights reserved.

public class ServicesCreationParams: BaseListingParams {
    
    public var serviceAttributes: ServiceAttributes
    
    public init(name: String?,
                description: String?,
                price: ListingPrice,
                category: ListingCategory,
                currency: Currency,
                location: LGLocationCoordinates2D,
                postalAddress: PostalAddress,
                images: [File],
                videos: [Video],
                serviceAttributes: ServiceAttributes) {
        self.serviceAttributes = serviceAttributes
        super.init(name: name,
                   description: description,
                   price: price,
                   category: category,
                   currency: currency,
                   location: location,
                   postalAddress: postalAddress,
                   languageCode: Locale.current.identifier,
                   images: images,
                   videos: videos)
    }
    
    func apiServiceCreationEncode(userId: String) -> [String: Any] {
        var params = super.apiCreationEncode(userId: userId)
        params.removeValue(forKey: CodingKeys.legacyPriceFlag.rawValue)
        
        var servicesAttributesDict: [String: Any] = [:]
        if let typeId = serviceAttributes.typeId {
            servicesAttributesDict[CodingKeys.typeId.rawValue] = typeId
        }
        if let subtypeId = serviceAttributes.subtypeId {
            servicesAttributesDict[CodingKeys.subTypeId.rawValue] = subtypeId
        }
        if let listingType = serviceAttributes.listingType {
            servicesAttributesDict[CodingKeys.listingType.rawValue] = listingType.rawValue
        }
        if let paymentFrequency = serviceAttributes.paymentFrequency {
            servicesAttributesDict[CodingKeys.paymentFrequency.rawValue] = paymentFrequency.rawValue
        }
        
        params[CodingKeys.images.rawValue] = images.compactMap { $0.objectId }
        params[CodingKeys.priceFlag.rawValue] = price.priceFlag.rawValue
        params[CodingKeys.serviceAttributes.rawValue] = servicesAttributesDict
        return params
    }
    
    enum CodingKeys: String {
        case typeId, subTypeId, listingType, paymentFrequency, images, priceFlag, serviceAttributes
        case legacyPriceFlag = "price_flag"
    }
}

extension Array where Element == ServicesCreationParams {
    func apiServicesCreationEncode(userId: String) -> [[String: Any]] {
        return map { $0.apiCreationEncode(userId: userId) }
    }
}
