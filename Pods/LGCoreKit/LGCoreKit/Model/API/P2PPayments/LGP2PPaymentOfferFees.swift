import Foundation

struct LGP2PPaymentOfferFees: P2PPaymentOfferFees, Decodable {
    let amount: Decimal
    let serviceFee: Decimal
    let serviceFeePercentage: Double
    let total: Decimal
    let currency: Currency
    var objectId: String? { return nil }

    enum CodingKeys : String, CodingKey {
        case amount = "net"
        case serviceFee = "service_fee"
        case serviceFeePercentage = "service_fee_percent"
        case total = "gross"
        case currency
    }
}

extension LGP2PPaymentOfferFees {
    struct Container: Decodable {
        private let data: Data
        var paymentOfferFees: LGP2PPaymentOfferFees { return data.paymentOfferFees }

        enum CodingKeys : String, CodingKey {
            case data
        }
    }

    private struct Data: Decodable {
        let paymentOfferFees: LGP2PPaymentOfferFees

        enum CodingKeys : String, CodingKey {
            case paymentOfferFees = "attributes"
        }
    }
}

/*
{
    "data": {
        "type": "offer-price-breakdown",
        "attributes": {
            "net": 5.95,
            "currency": "USD",
            "service_fee": 0.50,
            "service_fee_percent": 7.56,
            "gross": 6.44
        },
        "links": {
            "self": "http://p2payments.stg.letgo.cloud/api/offer-price-breakdown?amount=5.95&currency=USD"
        }
    }
}
*/
