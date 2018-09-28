extension P2PPaymentOfferStatus: MockFactory {
    public static func makeMock() -> P2PPaymentOfferStatus {
        let allValues: [P2PPaymentOfferStatus] = [.accepted, .pending, .declined, .canceled,
                                                  .error, .expired, .completed]
        return allValues.random()!
    }
}
