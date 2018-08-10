extension MockAvailableFeaturePurchases: MockFactory {
    public static func makeMock() -> MockAvailableFeaturePurchases {
        return MockAvailableFeaturePurchases(availablePurchases: MockFeaturePurchase.makeMocks(),
                                             featureInProgress: MockFeatureInProgress.makeMock())
    }
}
