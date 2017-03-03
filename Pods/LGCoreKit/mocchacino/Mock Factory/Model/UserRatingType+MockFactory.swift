extension UserRatingType: MockFactory {
    public static func makeMock() -> UserRatingType {
        switch Int.makeRandom(min: 0, max: 2) {
        case 0:
            return .conversation
        case 1:
            return .seller(productId: String.makeRandom())
        default:
            return .buyer(productId: String.makeRandom())
        }
    }
}
