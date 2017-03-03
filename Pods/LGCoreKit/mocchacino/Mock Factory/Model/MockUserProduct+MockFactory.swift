extension MockUserProduct: MockFactory {
    public static func makeMock() -> MockUserProduct {
        return MockUserProduct(objectId: String.makeRandom(),
                               name: String?.makeRandom(),
                               avatar: MockFile?.makeMock(),
                               postalAddress: PostalAddress.makeMock(),
                               status: UserStatus.makeMock(),
                               banned: Bool?.makeRandom(),
                               isDummy: Bool.makeRandom())
    }
}
