import Foundation

struct LGP2PPaymentCalculatePriceBreakdownParams {
    let amount: Decimal
    let currency: Currency

    var apiParams: [String : Any] {
        return ["amount": amount,
                "currency": currency.code]
    }
}
