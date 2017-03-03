import Foundation
@testable import LetGoGodMode
import LGCoreKit

extension MockPurchaseableProductsRequest: MockFactory {
    static func makeMock() -> MockPurchaseableProductsRequest {
        return MockPurchaseableProductsRequest(responseDelay: Double.makeRandom())
    }
}
