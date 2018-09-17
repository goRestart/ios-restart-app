import LGComponents

final class AffiliationInviteFriendsViewModel: BaseViewModel {
    var navigator: AffiliationInviteFriendsNavigator?

    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationInviteFriends()
        return true
    }

    func inviteSMSContactsButtonPressed() {
        navigator?.openAffiliationInviteSMSContacts()
    }
    
    func termsButtonPressed() {
        navigator?.openInviteTerms()
    }
}
