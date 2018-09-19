import Foundation

public struct P2PPaymentSeller {
    public let id: String
    public let hasAcceptedTOS: Bool
}

// MARK: - Decodable

extension P2PPaymentSeller: Decodable {
    private struct TermsOfService: Decodable {
        enum Service: String, Decodable {
            case stripe = "Stripe"
        }

        let service: Service
    }

    enum SellerRootKeys: String, CodingKey {
        case data
    }

    enum SellerDataKeys: String, CodingKey {
        case id
        case attributes
    }

    enum SellerAttributesKeys: String, CodingKey {
        case termsOfServices = "terms_of_services"
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: SellerRootKeys.self)
        let dataValues = try rootContainer.nestedContainer(keyedBy: SellerDataKeys.self, forKey: .data)
        if let attributes = try? dataValues.nestedContainer(keyedBy: SellerAttributesKeys.self, forKey: .attributes) {
            let acceptedTOS = try attributes.decodeIfPresent([TermsOfService].self, forKey: .termsOfServices) ?? []
            hasAcceptedTOS = acceptedTOS.contains(where: { $0.service == .stripe })
        } else {
            hasAcceptedTOS = false
        }
        id = try dataValues.decode(String.self, forKey: .id)
    }
}

//{
//    "data": {
//        "type": "sellers",
//        "id": "deb2bc77-3359-49c5-885b-90d20af04f4c",
//        "attributes": {
//            "first_name": "Ethyl",
//            "last_name": "Romaguera",
//            "personal_address": {
//                "line": "C/ Genova",
//                "city": "Madrid",
//                "zip_code": "08080",
//                "country_code": "ES"
//            },
//            "billing_address": {
//                "line": "C/ Genova",
//                "city": "Madrid",
//                "zip_code": "08080",
//                "country_code": "MA"
//            },
//            "terms_of_services": [
//            {
//            "service": "Stripe",
//            "ip": "212.12.23.12",
//            "accepted_on": "2018-01-02T10:23:43+00:00"
//            }
//            ],
//            "birth_date": "1995-08-03T00:00:00+00:00",
//            "created_at": "2018-08-24T14:22:27+00:00",
//            "updated_at": "2018-08-24T14:22:27+00:00"
//        },
//        "links": {
//            "self": "https://127.0.0.1:8000/api/sellers/deb2bc77-3359-49c5-885b-90d20af04f4c"
//        }
//    }
//}
