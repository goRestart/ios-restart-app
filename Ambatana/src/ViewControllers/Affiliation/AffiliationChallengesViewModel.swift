import LGComponents

final class AffiliationChallengesViewModel: BaseViewModel {
    var navigator: AffiliationChallengesNavigator?

    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationChallenges()
        return true
    }

    func inviteFriendsButtonPressed() {
        navigator?.openAffiliationInviteFriends()
    }

    func faqButtonPressed() {
        navigator?.openAffiliationFAQ()
    }
}
