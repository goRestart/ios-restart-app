public struct MockFeatureInProgress: FeatureInProgress {
    public var purchaseType: FeaturePurchaseType?
    public var secondsSinceLastFeature: TimeInterval
    public var featureDuration: TimeInterval
}
