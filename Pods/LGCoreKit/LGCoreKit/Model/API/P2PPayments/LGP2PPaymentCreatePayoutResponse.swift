import Foundation

struct LGP2PPaymentCreatePayoutResponse {
    let id: String
    let dataType: DataType

    enum DataType: String, Decodable {
        case payouts
    }
}

extension LGP2PPaymentCreatePayoutResponse: Decodable {
    enum PayoutRootKeys: String, CodingKey {
        case data
    }

    enum PayoutDataKeys: String, CodingKey {
        case type
        case id
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: PayoutRootKeys.self)
        let dataValues = try rootContainer.nestedContainer(keyedBy: PayoutDataKeys.self, forKey: .data)
        id = try dataValues.decode(String.self, forKey: .id)
        dataType = try dataValues.decode(DataType.self, forKey: .type)
    }
}

//{
//    "data": {
//        "type": "payouts",
//        "id": "0552b402-8e08-464c-8b0d-730006404379",
//        "links": {
//            "self": "payouts_url"
//        }
//    }
//}
