extension UserType: MockFactory {
    public static func makeMock() -> UserType {
        let allValues: [UserType] = [.user, .pro, .dummy]
        return allValues.random()!
    }
    
    public static func makeMockCarSeller() -> UserType {
        let carSellerValues = UserType.allNonDummyUserTypes
        return carSellerValues.random()!
    }
}
