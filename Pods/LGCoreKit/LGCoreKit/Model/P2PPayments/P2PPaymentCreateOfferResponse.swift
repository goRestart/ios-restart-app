import Foundation

struct P2PPaymentCreateOfferResponse: Decodable {
    let id: String
    let type: DataType

    enum DataType: String, Decodable {
        case offers
    }
}

extension P2PPaymentCreateOfferResponse {
    struct Container: Decodable {
        let response: P2PPaymentCreateOfferResponse

        enum CodingKeys : String, CodingKey {
            case response = "data"
        }
    }
}

/*
{
    "data": {
        "type": "offers",
        "id": "292f61b7-0db6-4213-9d80-4c8db32e0979"
    }
}
*/
