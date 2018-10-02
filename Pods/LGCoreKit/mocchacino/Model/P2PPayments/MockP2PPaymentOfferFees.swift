public struct MockP2PPaymentOfferFees: P2PPaymentOfferFees {
    public var objectId: String?
    public var amount: Decimal
    public var serviceFee: Decimal
    public var serviceFeePercentage: Double
    public var total: Decimal
    public var currency: Currency
}
