import Foundation
@testable import LetGoGodMode
import LGCoreKit

extension MockPurchaseableProduct: MockFactory {
    static func makeMock() -> MockPurchaseableProduct {
        return MockPurchaseableProduct(localizedDescription: String.makeRandom(),
                                       localizedTitle: String.makeRandom(),
                                       price: NSDecimalNumber(value: Int.random()),
                                       priceLocale: Locale.makeRandom(),
                                       productIdentifier: String.makeRandom(),
                                       downloadable: Bool.makeRandom(),
                                       downloadContentLengths: [Int].makeRandom().map { NSNumber(integerLiteral: $0) },
                                       downloadContentVersion: String.makeRandom())
    }
}
