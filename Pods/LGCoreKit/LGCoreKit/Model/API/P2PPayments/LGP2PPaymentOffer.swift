import Foundation

struct LGP2PPaymentOffer: P2PPaymentOffer {
    let id: String
    let buyerId: String
    let sellerId: String
    let listingId: String
    let offerStatus: Status
    let offerFees: LGP2PPaymentOfferFees
    var fees: P2PPaymentOfferFees { return offerFees }
    var status: P2PPaymentOfferStatus { return offerStatus.asP2PPaymentOfferStatus }
    var objectId: String? { return id }
}

// MARK: - Status

extension LGP2PPaymentOffer {
    enum Status: String, Decodable {
        case accepted
        case pending
        case declined
        case canceled
        case error
        case expired
        case completed

        var asP2PPaymentOfferStatus: P2PPaymentOfferStatus {
            switch self {
            case .accepted: return .accepted
            case .pending: return .pending
            case .declined: return .declined
            case .canceled: return .canceled
            case .error: return .error
            case .expired: return .expired
            case .completed: return .completed
            }
        }

        func apiParams(offerId: String) -> [String : Any] {
            let attributes: [String : Any] = ["status": rawValue]
            let data: [String : Any] = ["type": "offers",
                                        "id": offerId,
                                        "attributes": attributes]
            let params: [String : Any] = ["data" : data]
            return params
        }

        init(from p2pPaymentOfferStatus: P2PPaymentOfferStatus) {
            switch p2pPaymentOfferStatus {
            case .accepted: self = .accepted
            case .pending: self = .pending
            case .declined: self = .declined
            case .canceled: self = .canceled
            case .error: self = .error
            case .expired: self = .expired
            case .completed: self = .completed
            }
        }
    }
}

// MARK: - Decodable Container

extension LGP2PPaymentOffer: Decodable {
    enum PaymentOfferRootKeys: String, CodingKey {
        case data
    }

    enum PaymentOfferDataKeys: String, CodingKey {
        case id, attributes
    }

    enum CodingKeys: String, CodingKey {
        case buyerId = "buyer_id"
        case sellerId = "seller_id"
        case listingId = "listing_id"
        case status
        case gross
        case net
        case currency
        case fees
    }

    enum FeesKeys: String, CodingKey {
        case serviceFee = "service_fee"
        case serviceFeePercentage = "service_fee_percent"
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: PaymentOfferRootKeys.self)
        let dataValues = try rootContainer.nestedContainer(keyedBy: PaymentOfferDataKeys.self, forKey: .data)
        let attributes = try dataValues.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        let fees = try attributes.nestedContainer(keyedBy: FeesKeys.self, forKey: .fees)
        id = try dataValues.decode(String.self, forKey: .id)
        buyerId = try attributes.decode(String.self, forKey: .buyerId)
        sellerId = try attributes.decode(String.self, forKey: .sellerId)
        listingId = try attributes.decode(String.self, forKey: .listingId)
        offerStatus = try attributes.decode(Status.self, forKey: .status)
        let amount = try attributes.decode(Decimal.self, forKey: .net)
        let total = try attributes.decode(Decimal.self, forKey: .gross)
        let currency = try attributes.decode(Currency.self, forKey: .currency)
        let serviceFee = try fees.decode(Decimal.self, forKey: .serviceFee)
        let serviceFeePercentage = try fees.decode(Double.self, forKey: .serviceFeePercentage)
        offerFees = LGP2PPaymentOfferFees(amount: amount,
                                          serviceFee: serviceFee,
                                          serviceFeePercentage: serviceFeePercentage,
                                          total: total,
                                          currency: currency)
    }
}

/*
{
    "data": {
        "type": "offers",
        "id": "73e12c64-f4fd-4443-8dda-f955e8a28474",
        "attributes": {
            "offer_type": "online_payment",
            "listing_id": "b11b67fd-ece6-41bc-b35c-13a18377b047",
            "buyer_id": "deb2bc77-3359-49c5-885b-90d20af04f4c",
            "seller_id": "d861b09c-78be-4197-939a-4291d5e5a5fd",
            "status": "pending",
            "gross": 55.5,
            "net": 55.5,
            "currency": "USD",
            "fees": {
                "service_fee": 0,
                "service_fee_percent": 0
            },
            "created_at": "2018-07-20T06:43:14+00:00",
            "updated_at": "2018-07-20T06:43:14+00:00"
        },
        "links": {
            "self": "https:\/\/127.0.0.1:8000\/api\/offers\/73e12c64-f4fd-4443-8dda-f955e8a28474"
        }
    }
}
*/
