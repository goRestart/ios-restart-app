public struct MockPaymentItem: PaymentItem {
    public var provider: PaymentProvider
    public var itemId: String
    public var providerItemId: String
}
