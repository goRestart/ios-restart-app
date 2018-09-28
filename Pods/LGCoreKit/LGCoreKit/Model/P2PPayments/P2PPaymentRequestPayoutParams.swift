import Foundation

public struct P2PPaymentRequestPayoutParams {
    let offerId: String
    let stripeToken: String
    let isInstant: Bool

    public init(offerId: String,
                stripeToken: String,
                isInstant: Bool) {
        self.offerId = offerId
        self.stripeToken = stripeToken
        self.isInstant = isInstant
    }

    var apiParams: [String : Any] {
        let attributes: [String : Any] = ["offer_id": offerId,
                                          "payment_provider_seller_bank_account_token": stripeToken,
                                          "instant": isInstant]
        let data: [String : Any] = ["type": "payouts",
                                    "attributes": attributes]
        let params: [String : Any] = ["data" : data]
        return params
    }
}
