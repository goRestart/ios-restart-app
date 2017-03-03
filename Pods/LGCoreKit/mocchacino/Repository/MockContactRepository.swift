import Result

open class MockContactRepository: ContactRepository {
    public var result: ContactResult


    // MARK: - Lifecycle

    public init() {
        self.result = ContactResult(value: MockContact.makeMock())
    }


    // MARK: - ContactRepository

    public func send(_ contact: Contact, completion: ContactCompletion?) {
        delay(result: result, completion: completion)
    }
}
