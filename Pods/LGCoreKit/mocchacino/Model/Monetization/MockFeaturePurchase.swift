public struct MockFeaturePurchase: FeaturePurchase {
    public var purchaseType: FeaturePurchaseType?
    public var featureDuration: TimeInterval
    public var provider: PaymentProvider
    public var letgoItemId: String
    public var providerItemId: String
}
