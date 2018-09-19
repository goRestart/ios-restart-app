import Foundation

struct LGP2PPaymentPayCode {
    let offerId: String
    let payCode: String
}

// MARK: - Decodable Container

extension LGP2PPaymentPayCode: Decodable {
    enum PaymentPayCodeRootKeys: String, CodingKey {
        case data
    }

    enum PaymentPayCodeDataKeys: String, CodingKey {
        case attributes
    }

    enum CodingKeys: String, CodingKey {
        case code
        case offerId = "offer_id"
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: PaymentPayCodeRootKeys.self)
        let dataValues = try rootContainer.nestedContainer(keyedBy: PaymentPayCodeDataKeys.self, forKey: .data)
        let attributes = try dataValues.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes)
        offerId = try attributes.decode(String.self, forKey: .offerId)
        payCode = try attributes.decode(String.self, forKey: .code)
    }
}

/*
{
    "data": {
        "type": "paycode",
        "id": "c4f874cd-498e-4010-a34d-205b6278d21c",
        "attributes": {
            "code": "9A3B",
            "offer_id": "73e12c64-f4fd-4443-8dda-f955e8a28474"
        },
        "links": {
            "self": "https://localhost:8000/api/paycode/c4f874cd-498e-4010-a34d-205b6278d21c"
        }
    }
}
*/
