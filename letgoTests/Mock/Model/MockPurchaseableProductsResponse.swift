import Foundation
@testable import LetGoGodMode

struct MockPurchaseableProductsResponse: PurchaseableProductsResponse {
    var purchaseableProducts: [PurchaseableProduct]
    var invalidProductIdentifiers: [String]
}
