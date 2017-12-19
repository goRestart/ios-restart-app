extension ListingPrice: MockFactory {
    public static func makeMock() -> ListingPrice {
        switch Int.makeRandom(min: 0, max: 3) {
        case 0:
            return .free
        case 1:
            return .normal(Double.makeRandom())
        case 2:
            return .negotiable(Double.makeRandom())
        default:
            return .firmPrice(Double.makeRandom())
        }
    }
}
