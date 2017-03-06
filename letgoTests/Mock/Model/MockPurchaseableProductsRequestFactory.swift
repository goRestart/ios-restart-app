import Foundation
@testable import LetGoGodMode

class MockPurchaseableProductsRequestFactory: PurchaseableProductsRequestFactory {
    var responseDelay: TimeInterval = 0.03

    func generatePurchaseableProductsRequest(_ ids: [String]) -> PurchaseableProductsRequest {
        return MockPurchaseableProductsRequest(responseDelay: responseDelay)
    }
}
