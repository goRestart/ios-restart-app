import Foundation

public struct P2PPaymentCreateOfferParams {
    let listingId: String
    let buyerId: String
    let sellerId: String
    let amount: Double
    let currency: Currency
    let paymentToken: String

    public init(listingId: String,
                buyerId: String,
                sellerId: String,
                amount: Double,
                currency: Currency,
                paymentToken: String) {
        self.listingId = listingId
        self.buyerId = buyerId
        self.sellerId = sellerId
        self.amount = amount
        self.currency = currency
        self.paymentToken = paymentToken
    }

    var apiParams: [String : Any] {
        let paymentMethod: [String : Any] = ["type": "Stripe",
                                             "data": ["token": paymentToken]]
        let attributes: [String : Any] = ["type": "online_payment",
                                          "listing_id": listingId,
                                          "buyer_id": buyerId,
                                          "seller_id": sellerId,
                                          "net": amount,
                                          "currency": currency.code,
                                          "payment_method": paymentMethod]
        let data: [String : Any] = ["type": "offers",
                                    "attributes": attributes]
        let params: [String : Any] = ["data" : data]
        return params
    }
}
