public struct MockChatProduct: ChatProduct {
    public var objectId: String?
    public var name: String?
    public var status: ProductStatus
    public var image: File?
    public var price: ProductPrice
    public var currency: Currency
}
