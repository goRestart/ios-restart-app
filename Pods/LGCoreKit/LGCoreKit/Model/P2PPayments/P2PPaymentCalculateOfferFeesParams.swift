import Foundation

public struct P2PPaymentCalculateOfferFeesParams {
    let amount: Decimal
    let currency: Currency

    public init(amount: Decimal,
                currency: Currency) {
        self.amount = amount
        self.currency = currency
    }

    var apiParams: [String : Any] {
        return ["amount": amount,
                "currency": currency.code]
    }
}
