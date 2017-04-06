import Result

open class MockPassiveBuyersRepository: PassiveBuyersRepository {
    public var showResult: PassiveBuyersResult!
    public var contactResult: PassiveBuyersEmptyResult!


    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - PassiveBuyersRepository {

    public func show(productId: String, completion: PassiveBuyersCompletion?) {
        delay(result: showResult, completion: completion)
    }

    public func contactAllBuyers(passiveBuyersInfo: PassiveBuyersInfo, completion: PassiveBuyersEmptyCompletion?){
        delay(result: contactResult, completion: completion)
    }
}
