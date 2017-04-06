extension MockUserListing: MockFactory {
    public static func makeMock() -> MockUserListing {
        return MockUserListing(objectId: String.makeRandom(),
                               name: String?.makeRandom(),
                               avatar: MockFile?.makeMock(),
                               postalAddress: PostalAddress.makeMock(),
                               status: UserStatus.makeMock(),
                               banned: Bool?.makeRandom(),
                               isDummy: Bool.makeRandom())
    }
}
