extension MockMyUser: MockFactory {
    public static func makeMock() -> MockMyUser {
        return MockMyUser(objectId: String.makeRandom(),
                          name: String?.makeRandom(),
                          avatar: MockFile?.makeMock(),
                          postalAddress: PostalAddress.makeMock(),
                          accounts: MockAccount.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                          ratingAverage: Float?.makeRandom(),
                          ratingCount: Int.makeRandom(),
                          status: UserStatus.makeMock(),
                          isDummy: Bool.makeRandom(),
                          email: String.makeRandomEmail(),
                          location: LGLocation?.makeMock(),
                          localeIdentifier: String?.makeRandom())
    }
}
