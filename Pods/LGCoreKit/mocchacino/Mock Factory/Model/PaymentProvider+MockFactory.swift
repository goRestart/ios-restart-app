extension PaymentProvider: MockFactory {
    public static func makeMock() -> PaymentProvider {
        return PaymentProvider.allValues.random()!
    }
}
