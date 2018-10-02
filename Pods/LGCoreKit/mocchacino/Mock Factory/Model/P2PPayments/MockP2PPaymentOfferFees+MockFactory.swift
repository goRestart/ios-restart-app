extension MockP2PPaymentOfferFees: MockFactory {
    public static func makeMock() -> MockP2PPaymentOfferFees {
        return MockP2PPaymentOfferFees(objectId: String.makeRandom(),
                                       amount: Decimal(floatLiteral: Double.makeRandom()),
                                       serviceFee: Decimal(floatLiteral: Double.makeRandom()),
                                       serviceFeePercentage: Double.makeRandom(),
                                       total: Decimal(floatLiteral: Double.makeRandom()),
                                       currency: Currency.makeMock())
    }
}
