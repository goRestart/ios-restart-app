import LGCoreKit

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
