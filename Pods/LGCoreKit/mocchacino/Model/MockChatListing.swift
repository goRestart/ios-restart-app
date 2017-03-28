public struct MockChatListing: ChatListing {
    public var objectId: String?
    public var name: String?
    public var status: ListingStatus
    public var image: File?
    public var price: ProductPrice
    public var currency: Currency
    
    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["id"] = objectId
        result["name"] = name
        result["status"] = status.rawValue
        result["image"] = image?.fileURL
        result["price"] = ["amount": price.value, "flag": price.priceFlag.rawValue, "currency": currency.code]
        return result
    }
}
