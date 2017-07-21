public struct MockChatListing: ChatListing {
    public var objectId: String?
    public var name: String?
    public var status: ListingStatus
    public var image: File?
    public var price: ListingPrice
    public var currency: Currency
    
    public init(objectId: String?,
                name: String?,
                status: ListingStatus,
                image: File?,
                price: ListingPrice,
                currency: Currency) {
        self.objectId = objectId
        self.name = name
        self.status = status
        self.image = image
        self.price = price
        self.currency = currency
    }
    
    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["id"] = objectId
        result["name"] = name
        result["status"] = status.rawValue
        result["image"] = image?.fileURL?.absoluteString
        result["price"] = ["amount": price.value, "flag": price.priceFlag.rawValue, "currency": currency.code]
        return result
    }
}
