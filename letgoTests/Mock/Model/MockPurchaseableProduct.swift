import Foundation
@testable import LetGo
import LGCoreKit

struct MockPurchaseableProduct: PurchaseableProduct {
    var localizedDescription: String
    var localizedTitle: String
    var price: NSDecimalNumber
    var priceLocale: Locale
    var productIdentifier: String
    var downloadable: Bool
    var downloadContentLengths: [NSNumber]
    var downloadContentVersion: String

    init(localizedDescription: String,
         localizedTitle: String,
         price: NSDecimalNumber,
         priceLocale: Locale,
         productIdentifier: String,
         downloadable: Bool,
         downloadContentLengths: [NSNumber],
         downloadContentVersion: String) {
        self.localizedDescription = localizedDescription
        self.localizedTitle = localizedTitle
        self.price = price
        self.priceLocale = priceLocale
        self.productIdentifier = productIdentifier
        self.downloadable = downloadable
        self.downloadContentLengths = downloadContentLengths
        self.downloadContentVersion = downloadContentVersion
    }
}
