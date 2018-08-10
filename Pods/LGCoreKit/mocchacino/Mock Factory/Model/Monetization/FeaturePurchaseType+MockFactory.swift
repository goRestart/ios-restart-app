extension FeaturePurchaseType: MockFactory {
    public static func makeMock() -> FeaturePurchaseType {
        return FeaturePurchaseType.allValues.random()!
    }
}
