extension MockFeaturePurchase: MockFactory {
    public static func makeMock() -> MockFeaturePurchase {
        return MockFeaturePurchase(purchaseType: FeaturePurchaseType.makeMock(),
                                   featureDuration: TimeInterval(Int.makeRandom()),
                                   provider: PaymentProvider.makeMock(),
                                   letgoItemId: String.makeRandom(),
                                   providerItemId: String.makeRandom())
    }
}
