extension MockFeatureInProgress: MockFactory {
    public static func makeMock() -> MockFeatureInProgress {
        return MockFeatureInProgress(purchaseType: FeaturePurchaseType.makeMock(),
                                   secondsSinceLastFeature: TimeInterval(Int.makeRandom()),
                                   featureDuration: TimeInterval(Int.makeRandom()))
    }
}
