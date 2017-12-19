extension MockPaymentItem: MockFactory {
    public static func makeMock() -> MockPaymentItem {
        return MockPaymentItem(provider: PaymentProvider.makeMock(),
                               itemId: String.makeRandom(),
                               providerItemId: String.makeRandom())
    }
}
