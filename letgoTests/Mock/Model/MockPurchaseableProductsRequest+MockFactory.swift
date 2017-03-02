import Foundation
@testable import LetGo
import LGCoreKit

extension MockPurchaseableProductsRequest: MockFactory {
    static func makeMock() -> MockPurchaseableProductsRequest {
        return MockPurchaseableProductsRequest(responseDelay: Double.makeRandom())
    }
}
