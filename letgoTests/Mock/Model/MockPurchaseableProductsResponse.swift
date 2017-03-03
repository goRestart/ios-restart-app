import Foundation
@testable import LetGo

struct MockPurchaseableProductsResponse: PurchaseableProductsResponse {
    var purchaseableProducts: [PurchaseableProduct]
    var invalidProductIdentifiers: [String]
}
