import LGComponents

final class AffiliationChallengesViewModel: BaseViewModel {
    var navigator: AffiliationChallengesNavigator?

    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationChallenges()
        return true
    }

    func storeButtonPressed() {
        navigator?.openAffiliationStore()
    }

    func inviteFriendsButtonPressed() {
        navigator?.openAffiliationInviteFriends()
    }

    func faqButtonPressed() {
        navigator?.openAffiliationFAQ()
    }

    func confirmPhoneButtonPressed() {
        navigator?.openConfirmPhone()
    }

    func postListingButtonPressed() {
        navigator?.openPostListing()
    }
}
