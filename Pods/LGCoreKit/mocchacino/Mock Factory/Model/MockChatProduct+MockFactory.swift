extension MockChatProduct: MockFactory {
    public static func makeMock() -> MockChatProduct {
        return MockChatProduct(objectId: String.makeRandom(),
                               name: String?.makeRandom(),
                               status: ProductStatus.makeMock(),
                               image: MockFile?.makeMock(),
                               price: ProductPrice.makeMock(),
                               currency: Currency.makeMock())
    }
}
