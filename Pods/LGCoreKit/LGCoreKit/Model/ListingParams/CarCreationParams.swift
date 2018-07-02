public class CarCreationParams: BaseListingParams {
    
    public var carAttributes: CarAttributes
    
    public init(name: String?,
                description: String?,
                price: ListingPrice,
                category: ListingCategory,
                currency: Currency,
                location: LGLocationCoordinates2D,
                postalAddress: PostalAddress,
                images: [File],
                videos: [Video],
                carAttributes: CarAttributes) {
        self.carAttributes = carAttributes
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
    
    override func apiCreationEncode(userId: String) -> [String: Any] {
        var params = super.apiCreationEncode(userId: userId)
        params.removeValue(forKey: "price_flag")
        params[CodingKeys.carAttributes.rawValue] = carAttributes.dictionaryEncoded
        params[CodingKeys.images.rawValue] = images.flatMap { $0.objectId }
        params[CodingKeys.priceFlag.rawValue] = price.priceFlag.rawValue
        return params
    }
    
    private enum CodingKeys: String {
        case carAttributes, images, priceFlag
    }
}
