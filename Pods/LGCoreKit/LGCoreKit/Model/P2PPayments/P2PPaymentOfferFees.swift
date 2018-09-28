import Foundation

public protocol P2PPaymentOfferFees: BaseModel {
    var amount: Decimal { get }
    var serviceFee: Decimal { get }
    var serviceFeePercentage: Double { get }
    var total: Decimal { get }
    var currency: Currency { get }
}
