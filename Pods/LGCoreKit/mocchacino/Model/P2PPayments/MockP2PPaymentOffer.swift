public struct MockP2PPaymentOffer: P2PPaymentOffer {
    public var objectId: String?
    public var buyerId: String
    public var sellerId: String
    public var listingId: String
    public var status: P2PPaymentOfferStatus
    public var fees: P2PPaymentOfferFees
    public var fundsAvailableDate: Date?
}
