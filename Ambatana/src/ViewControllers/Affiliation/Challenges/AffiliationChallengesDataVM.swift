struct AffiliationChallengesDataVM {
    let walletPoints: Int
    let challenges: [Challenge]

    var numberOfChallenges: Int {
        return challenges.count
    }

    func challengeAt(index: Int) -> Challenge? {
        return challenges[safeAt: index]
    }
}

// Move this to core

enum Challenge {
    case inviteFriends(ChallengeInviteFriendsData)
    case joinLetgo(ChallengeJoinLetgoData)

    var status: ChallengeStatus {
        switch self {
        case let .inviteFriends(data):
            return data.status
        case let .joinLetgo(data):
            return data.status
        }
    }
}

enum ChallengeStatus {
    case ongoing, completed
}

struct ChallengeMilestone {
    let stepIndex: Int
    let pointsReward: Int
}

struct ChallengeInviteFriendsData {
    let milestones: [ChallengeMilestone]
    let stepsCount: Int
    let currentStep: Int
    let status: ChallengeStatus

    func calculateTotalPointsReward() -> Int {
        return milestones.reduce(0) { partial, milestone in partial + milestone.pointsReward }
    }
}

struct ChallengeJoinLetgoData {
    enum Step {
        case phoneVerification, listingPosted
    }
    let stepsCount: Int
    let stepsCompleted: [Step]
    let pointsReward: Int
    let status: ChallengeStatus
}
