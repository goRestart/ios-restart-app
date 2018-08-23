public struct MockAvailableFeaturePurchases: AvailableFeaturePurchases {
    public var availablePurchases: [FeaturePurchase]
    public var featureInProgress: FeatureInProgress?
}
