
public enum Challenge {
    case inviteFriends(ChallengeInviteFriendsData)
    case joinLetgo(ChallengeJoinLetgoData)
    
    public var status: ChallengeStatus {
        switch self {
        case let .inviteFriends(data):
            return data.status
        case let .joinLetgo(data):
            return data.status
        }
    }
}

public enum ChallengeStatus: String, Decodable {
    case ongoing, completed, pending
}

public struct ChallengeMilestone {
    public let stepIndex: Int
    public let pointsReward: Int
}

public struct ChallengeInviteFriendsData {
    public let id: String
    public let milestones: [ChallengeMilestone]
    public let stepsCount: Int
    public let currentStep: Int
    public let status: ChallengeStatus
    
    public func calculateTotalPointsReward() -> Int {
        return milestones.reduce(0) { partial, milestone in partial + milestone.pointsReward }
    }
}

public struct ChallengeJoinLetgoData {
    public enum Step: String, Decodable {
        case phoneVerification = "phone_verification", listingPosted = "listing_posted"
    }
    public let id: String
    public let stepsCount: Int
    public let stepsCompleted: [Step]
    public let pointsReward: Int
    public let status: ChallengeStatus
}

extension Challenge: Decodable {
    
    enum ChallengeRootKeys: String, CodingKey {
        case type, id, attributes
    }
    
    public enum ChallengeType: String, Decodable {
        case inviteFriends = "referred_friend", joinLetgo = "join_letgo"
    }
    
    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: ChallengeRootKeys.self)
        let challengeType = try rootContainer.decode(ChallengeType.self, forKey: .type)
        switch challengeType {
        case .inviteFriends:
            let challengeInviteFriendsData = try ChallengeInviteFriendsData(from: decoder)
            self = .inviteFriends(challengeInviteFriendsData)
        case .joinLetgo:
            let challengeJoinLetgoData = try ChallengeJoinLetgoData(from: decoder)
            self = .joinLetgo(challengeJoinLetgoData)
        }
    }
}

extension ChallengeMilestone: Decodable {
    
    /*
     {
     "step": 3,
     "points": 10
     }
     */
    
    enum ChallengeMilestoneKeys: String, CodingKey {
        case stepIndex = "step", pointsReward = "points"
    }
    
    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: ChallengeMilestoneKeys.self)
        stepIndex = try rootContainer.decode(Int.self, forKey: .stepIndex)
        pointsReward = try rootContainer.decode(Int.self, forKey: .pointsReward)
    }
}



extension ChallengeInviteFriendsData: Decodable {
    
    /*
     "type": "referred_friend",
     "id": "de79e39b-5d31-49ca-8bfa-7a7263604fb8",
     "attributes": {
       "total_steps": 10,
       "step_points": [
       {
         "step": 3,
         "points": 10
       },
       {
         "step": 10,
         "points": 50
       }
       ],
       "status": "ongoing",
       "current_step": 0
     }
     */
    
    enum ChallengeInviteFriendsDataAttributeKeys: String, CodingKey {
        case totalSteps = "total_steps", status, currentStep = "current_step", stepPoints = "step_points"
    }
    
    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: Challenge.ChallengeRootKeys.self)
        id = try rootContainer.decode(String.self, forKey: .id)
        let attributesContainer = try rootContainer.nestedContainer(keyedBy: ChallengeInviteFriendsDataAttributeKeys.self, forKey: .attributes)
        stepsCount = try attributesContainer.decode(Int.self, forKey: .totalSteps)
        currentStep = try attributesContainer.decode(Int.self, forKey: .currentStep)
        status = try attributesContainer.decode(ChallengeStatus.self, forKey: .status)
        milestones = try attributesContainer.decode([ChallengeMilestone].self, forKey: .stepPoints)
    }
}

extension ChallengeJoinLetgoData: Decodable {
    
    /*
     "type": "join_letgo",
     "id": "xxx", // userId to identify,
     "attributes": {
       "total_steps": 2,
       "steps_completed": ["phone_verification", "listing_posted"],
       "points": 5,
       "status": "completed" // ongoing|completed|disabled|pending
     }
    */
    
    enum ChallengeJoinLetgoDataAttributeKeys: String, CodingKey {
        case totalSteps = "total_steps", stepsCompleted = "steps_completed", points, status
    }
    
    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: Challenge.ChallengeRootKeys.self)
        id = try rootContainer.decode(String.self, forKey: .id)
        let attributesContainer = try rootContainer.nestedContainer(keyedBy: ChallengeJoinLetgoDataAttributeKeys.self, forKey: .attributes)
        stepsCount = try attributesContainer.decode(Int.self, forKey: .totalSteps)
        stepsCompleted = try attributesContainer.decode([Step].self, forKey: .stepsCompleted)
        status = try attributesContainer.decode(ChallengeStatus.self, forKey: .status)
        pointsReward = try attributesContainer.decode(Int.self, forKey: .points)
    }
}
