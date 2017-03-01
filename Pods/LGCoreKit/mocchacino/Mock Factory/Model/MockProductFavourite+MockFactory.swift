extension MockProductFavourite: MockFactory {
    public static func makeMock() -> MockProductFavourite {
        return MockProductFavourite(objectId: String.makeRandom(),
                                    product: MockProduct.makeMock(),
                                    user: MockUserProduct.makeMock())
    }
}
