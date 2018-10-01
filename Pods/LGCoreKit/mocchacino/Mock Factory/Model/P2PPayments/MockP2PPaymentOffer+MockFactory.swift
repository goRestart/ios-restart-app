extension MockP2PPaymentOffer: MockFactory {
    public static func makeMock() -> MockP2PPaymentOffer {
        return MockP2PPaymentOffer(objectId: String?.makeRandom(),
                                   buyerId: String.makeRandom(),
                                   sellerId: String.makeRandom(),
                                   listingId: String.makeRandom(),
                                   status: P2PPaymentOfferStatus.makeMock(),
                                   fees: MockP2PPaymentOfferFees.makeMock(),
                                   fundsAvailableDate: Date?.makeRandom())
    }
}
