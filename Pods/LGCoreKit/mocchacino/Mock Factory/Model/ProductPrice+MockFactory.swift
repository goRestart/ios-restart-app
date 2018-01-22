extension ListingPrice: MockFactory {
    public static func makeMock() -> ListingPrice {
        switch Int.makeRandom(min: 0, max: 1) {
        case 0:
            return .free
        default:
            return .normal(Double.makeRandom())
        }
    }
}
