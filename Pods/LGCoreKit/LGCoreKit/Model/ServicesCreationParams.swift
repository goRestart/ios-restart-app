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
        
        var servicesAttributesDict: [String: Any] = [:]
        if let typeId = serviceAttributes.typeId {
            servicesAttributesDict["typeId"] = typeId
        }
        if let subtypeId = serviceAttributes.subtypeId {
            servicesAttributesDict["subTypeId"] = subtypeId
        }
        params["serviceAttributes"] = servicesAttributesDict
        return params
    }
    
}

extension Array where Element == ServicesCreationParams {
    func apiServicesCreationEncode(userId: String) -> [[String: Any]] {
        return map { $0.apiCreationEncode(userId: userId) }
    }
}
