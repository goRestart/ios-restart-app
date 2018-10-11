@testable import LGCoreKit

extension Challenge: MockFactory {
    
    public static func makeMock() -> Challenge {
        let joinLetgo = ChallengeJoinLetgoData(id: String.makeRandom(),
                                               stepsCount: Int.makeRandom(),
                                               stepsCompleted: [ChallengeJoinLetgoData.Step.makeRandom()],
                                               pointsReward: Int.makeRandom(),
                                               status: ChallengeStatus.makeRandom())
        let inviteFriendsData = ChallengeInviteFriendsData(id: String.makeRandom(),
                                                           milestones: [ChallengeMilestone.makeRandom()],
                                                           stepsCount: Int.makeRandom(),
                                                           currentStep: Int.makeRandom(),
                                                           status: ChallengeStatus.makeRandom())
        return Int.makeRandom(min: 0, max: 1) == 0 ? .joinLetgo(joinLetgo) : .inviteFriends(inviteFriendsData)
    }
}


extension ChallengeJoinLetgoData.Step: MockFactory, Randomizable {
    
    public static func makeMock() -> ChallengeJoinLetgoData.Step {
        return self.makeRandom()
    }
    
    public static func makeRandom() -> ChallengeJoinLetgoData.Step {
        let steps = ChallengeJoinLetgoData.Step.allValues
        return steps[Int.makeRandom(min: 0, max: steps.count - 1)]
    }
}

extension ChallengeStatus: Randomizable {
    
    public static func makeRandom() -> ChallengeStatus {
        let status = ChallengeStatus.allValues
        return status[Int.makeRandom(min: 0, max: status.count - 1)]
    }
}

extension ChallengeMilestone: Randomizable {
    
    public static func makeRandom() -> ChallengeMilestone {
        return ChallengeMilestone(stepIndex: Int.makeRandom(), pointsReward: Int.makeRandom())
    }
}
