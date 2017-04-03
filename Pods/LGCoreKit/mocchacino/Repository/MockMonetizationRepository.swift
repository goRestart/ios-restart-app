import Result

open class MockMonetizationRepository: MonetizationRepository {
    public var retrieveResult: BumpeableProductResult!
    public var bumpResult: BumpResult!


    // MARK: - Lifecycle

    required public init() {
        
    }


    // MARK: - MonetizationRepository

    public func retrieveBumpeableProductInfo(productId: String, completion: BumpeableProductCompletion?) {
        delay(result: retrieveResult, completion: completion)
    }

    public func freeBump(forProduct productId: String, itemId: String, completion: BumpCompletion?) {
        delay(result: bumpResult, completion: completion)
    }

    public func pricedBump(forProduct productId: String, receiptData: String, itemId: String, itemPrice: String,
                           itemCurrency: String, completion: BumpCompletion?) {
        delay(result: bumpResult, completion: completion)
    }
}
