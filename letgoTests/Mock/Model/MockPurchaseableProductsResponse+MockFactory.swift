import Foundation
@testable import LetGo
import LGCoreKit

extension MockPurchaseableProductsResponse: MockFactory {
    static func makeMock() -> MockPurchaseableProductsResponse {
        return MockPurchaseableProductsResponse(purchaseableProducts: MockPurchaseableProduct.makeMocks(),
                                                invalidProductIdentifiers: [String].makeRandom())
    }
}
