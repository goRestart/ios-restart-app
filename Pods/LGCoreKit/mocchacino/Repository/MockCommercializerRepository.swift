import Result

open class MockCommercializerRepository: CommercializerRepository {
    public var indexResult: CommercializersResult
    

    // MARK: - Lifecycle

    public init() {
        self.indexResult = CommercializersResult(value: MockCommercializer.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }


    // MARK: - CommercializerRepository

    public func index(_ productId: String, completion: CommercializersCompletion?) {
        delay(result: indexResult, completion: completion)
    }
}
