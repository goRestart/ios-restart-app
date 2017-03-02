import Result

open class MockPassiveBuyersRepository: PassiveBuyersRepository {
    public var showResult: PassiveBuyersResult
    public var contactResult: PassiveBuyersEmptyResult


    // MARK: - Lifecycle

    public init() {
        self.showResult = PassiveBuyersResult(value: MockPassiveBuyersInfo.makeMock())
        self.contactResult = PassiveBuyersEmptyResult(value: Void())
    }


    // MARK: - PassiveBuyersRepository {

    public func show(productId: String, completion: PassiveBuyersCompletion?) {
        delay(result: showResult, completion: completion)
    }

    public func contactAllBuyers(passiveBuyersInfo: PassiveBuyersInfo, completion: PassiveBuyersEmptyCompletion?){
        delay(result: contactResult, completion: completion)
    }
}
