import Foundation

struct P2PPaymentGetStateResponse: Decodable {
  let id: P2PPaymentState
}

extension P2PPaymentGetStateResponse {
  struct Container: Decodable {
    let response: P2PPaymentGetStateResponse
    
    enum CodingKeys: String, CodingKey {
      case response = "data"
    }
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
