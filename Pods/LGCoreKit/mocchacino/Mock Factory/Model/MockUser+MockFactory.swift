extension MockUser: MockFactory {
    public static func makeMock() -> MockUser {
        return MockUser(objectId: String.makeRandom(),
                        name: String?.makeRandom(),
                        avatar: MockFile?.makeMock(),
                        postalAddress: PostalAddress.makeMock(),
                        accounts: MockAccount.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                        ratingAverage: Float?.makeRandom(),
                        ratingCount: Int.makeRandom(),
                        status: UserStatus.makeMock(),
                        isDummy: Bool.makeRandom())
    }
}
