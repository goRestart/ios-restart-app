
struct LGReward: Reward {
    let id: String
    let type: RewardType
    let points: Int
}

extension LGReward: Decodable {
    
    /*
     {
     "type": "items",
     "id": "amazon_5_CA",
     "attributes": {
       "type": "amazon_5",
       "points": 5,
       "country_code": "CA"
     }
     }
     */
    
    enum RewardRootKeys: String, CodingKey {
        case type, id, attributes
    }
    
    enum RewardAttributeKeys: String, CodingKey {
        case type, points
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RewardRootKeys.self)
        id = try rootContainer.decode(String.self, forKey: .id)
        let attributesContainer = try rootContainer.nestedContainer(keyedBy: RewardAttributeKeys.self, forKey: .attributes)
        type = try attributesContainer.decode(RewardType.self, forKey: .type)
        points = try attributesContainer.decode(Int.self, forKey: .points)
    }
}
