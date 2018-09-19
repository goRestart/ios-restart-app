import Foundation

struct P2PPaymentGetStateResponse {
    let state: State
    let offerId: String?

    enum State: String, Decodable {
        case makeOffer = "make_offer"
        case viewPayCode = "view_pay_code"
        case offersUnavailable = "offers_unavailable"
        case viewOffer = "view_offer"
        case exchangeCode = "exchange_code"
        case payout = "payout"
    }

    func asPaymentState() -> P2PPaymentState {
        switch (state, offerId) {
        case (.makeOffer, _):
            return .makeOffer
        case (.viewPayCode, .some(let id)):
            return .viewPayCode(offerId: id)
        case (.offersUnavailable, _):
            return .offersUnavailable
        case (.viewOffer, .some(let id)):
            return .viewOffer(offerId: id)
        case (.exchangeCode, .some(let id)):
            return .exchangeCode(offerId: id)
        case (.payout, .some(let id)):
            return .payout(offerId: id)
        default:
            return .offersUnavailable
        }
    }
}

// MARK: - Decodable Container

extension P2PPaymentGetStateResponse: Decodable {
    enum GetStateRootKeys: String, CodingKey {
        case data
    }

    enum GetStateDataKeys: String, CodingKey {
        case id
        case attributes
    }

    enum CodingKeys: String, CodingKey {
        case offerId = "offer_id"
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: GetStateRootKeys.self)
        let dataValues = try rootContainer.nestedContainer(keyedBy: GetStateDataKeys.self, forKey: .data)
        if let attributes = try? dataValues.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributes) {
            offerId = try attributes.decodeIfPresent(String.self, forKey: .offerId)
        } else {
            offerId = nil
        }
        state = try dataValues.decode(State.self, forKey: .id)
    }
}

/*
{
  "data": {
    "type": "app-state",
    "id": "payout",
    "attributes": {
      "offer_id": "4bbfebed-3a4e-40e8-ad18-065c14e16701"
    },
    "links": {
      "self": "https://127.0.0.1:8000/api/app-state?version=1&buyerId=947fcd5f-6aea-475e-a766-76acfb02bd05&sellerId=9c33deaf-74f3-4da9-bf99-c11c39752b83&listingId=dbd462a1-ae32-44a5-96cd-1f81617a7743"
    }
  }
}*/
