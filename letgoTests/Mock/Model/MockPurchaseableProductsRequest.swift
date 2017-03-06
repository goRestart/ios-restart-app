import Foundation
@testable import LetGoGodMode

final class MockPurchaseableProductsRequest: PurchaseableProductsRequest {
    weak var delegate: PurchaseableProductsRequestDelegate?

    fileprivate var timer: Timer = Timer()
    fileprivate let responseDelay: TimeInterval

    init(responseDelay: TimeInterval) {
        self.responseDelay = responseDelay
    }

    func start() {
        timer = Timer.scheduledTimer(timeInterval: responseDelay,
                                     target: self,
                                     selector: #selector(launchResponse),
                                     userInfo: nil,
                                     repeats: false)
    }

    func cancel() {
        timer.invalidate()
    }

    dynamic func launchResponse() {
        let response = MockPurchaseableProductsResponse(purchaseableProducts: MockPurchaseableProduct.makeMocks(),
                                                        invalidProductIdentifiers: [])
        delegate?.productsRequest(self, didReceiveResponse: response)
    }
}
