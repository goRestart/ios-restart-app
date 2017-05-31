extension CreateTransactionParams: MockFactory {
    public static func makeMock() -> CreateTransactionParams {
        return CreateTransactionParams(listingId: String.makeRandom(), buyerId: String.makeRandom() , soldIn: SoldIn.allValues.random()!)
    }
}
