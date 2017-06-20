import Result
import RxSwiftExt
import RxSwift

open class MockMonetizationRepository: MonetizationRepository {
    
    public var eventsPublishSubject = PublishSubject<MonetizationEvent>()
    
    public var events: Observable<MonetizationEvent> {
        return eventsPublishSubject.asObservable()
    }
    
    public var retrieveResult: BumpeableListingResult!
    public var bumpResult: BumpResult!


    // MARK: - Lifecycle

    required public init() {

    }


    // MARK: - MonetizationRepository

    public func retrieveBumpeableProductInfo(productId: String, completion: BumpeableListingCompletion?) {
        delay(result: retrieveResult, completion: completion)
    }

    public func freeBump(forListingId listingId: String, itemId: String, completion: BumpCompletion?) {
        delay(result: bumpResult, completion: completion)
    }

    public func pricedBump(forListingId listingId: String, receiptData: String, itemId: String, itemPrice: String,
                           itemCurrency: String, amplitudeId: String?, appsflyerId: String?, idfa: String?,
                           bundleId: String?, completion: BumpCompletion?) {
        delay(result: bumpResult, completion: completion)
    }
}
