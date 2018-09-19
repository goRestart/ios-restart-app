
struct LGRewardPoints: RewardPoints {
    let points: Int
}

extension LGRewardPoints: Decodable {
    
    /*
     {
     "type": "points",
     "id": "de79e39b-5d31-49ca-8bfa-7a7263604fb8" // user-id
     "attributes": {
       "value": 1000
     }
     */
    
    enum RewardPointsRootKeys: String, CodingKey {
        case type, id, attributes
    }
    
    enum RewardPointsAttributeKeys: String, CodingKey {
        case value
    }
    
    init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RewardPointsRootKeys.self)
        let attributesContainer = try rootContainer.nestedContainer(keyedBy: RewardPointsAttributeKeys.self, forKey: .attributes)
        points = try attributesContainer.decode(Int.self, forKey: .value)
    }
}
