import Foundation

public struct P2PPaymentPayoutPriceBreakdown {
    public let originalAmount: Decimal
    public let receivedAmount: Decimal
    public let fee: Decimal
    public let feePercentage: Double
    public let currency: Currency
}

extension P2PPaymentPayoutPriceBreakdown: Decodable {
    enum PayoutPriceBreakdownRootKeys: String, CodingKey {
        case data
    }

    enum PayoutPriceBreakdownDataKeys: String, CodingKey {
        case attributes
    }

    enum CodingKeys: String, CodingKey {
        case originalAmount
        case receivedAmount
        case fee
        case feePercentage = "feePercent"
        case currency
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: PayoutPriceBreakdownRootKeys.self)
        let dataContainer = try rootContainer.nestedContainer(keyedBy: PayoutPriceBreakdownDataKeys.self, forKey: .data)
        let attributes = try dataContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        originalAmount = try attributes.decode(Decimal.self, forKey: .originalAmount)
        receivedAmount = try attributes.decode(Decimal.self, forKey: .receivedAmount)
        fee = try attributes.decode(Decimal.self, forKey: .fee)
        feePercentage = try attributes.decode(Double.self, forKey: .feePercentage)
        currency = try attributes.decode(Currency.self, forKey: .currency)
    }
}

//{
//    "data": {
//        "type": "payout-provider-price-breakdown",
//        "attributes": {
//            "originalAmount": 50.2,
//            "receivedAmount": 49.45,
//            "fee": 0.75,
//            "feePercent": 1.5,
//            "currency": "USD"
//        },
//        "links": {
//            "self": "/api/payout-stripe-price-breakdown?amount=50.2&currency=USD"
//        }
//    }
//}
