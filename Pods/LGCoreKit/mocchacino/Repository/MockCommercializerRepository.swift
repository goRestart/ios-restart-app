import Result

open class MockCommercializerRepository: CommercializerRepository {
    public var indexResult: CommercializersResult!
    

    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - CommercializerRepository

    public func index(_ listingId: String, completion: CommercializersCompletion?) {
        delay(result: indexResult, completion: completion)
    }
}
