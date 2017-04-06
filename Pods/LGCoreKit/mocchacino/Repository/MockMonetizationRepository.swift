import Result

open class MockMonetizationRepository: MonetizationRepository {
    public var retrieveResult: BumpeableListingResult!
    public var bumpResult: BumpResult!


    // MARK: - Lifecycle

    required public init() {

    }


    // MARK: - MonetizationRepository

    public func retrieveBumpeableProductInfo(productId: String, completion: BumpeableListingCompletion?) {
        delay(result: retrieveResult, completion: completion)
    }

    public func freeBump(forProduct productId: String, itemId: String, completion: BumpCompletion?) {
        delay(result: bumpResult, completion: completion)
    }

    public func pricedBump(forProduct productId: String, receiptData: String, itemId: String, itemPrice: String,
                           itemCurrency: String, amplitudeId: String?, appsflyerId: String?, idfa: String?,
                           bundleId: String?, completion: BumpCompletion?) {
        delay(result: bumpResult, completion: completion)
    }
}
