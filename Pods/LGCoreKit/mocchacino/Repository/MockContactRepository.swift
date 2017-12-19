import Result

open class MockContactRepository: ContactRepository {
    public var result: ContactResult!


    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - ContactRepository

    public func send(_ contact: Contact, completion: ContactCompletion?) {
        delay(result: result, completion: completion)
    }
}
