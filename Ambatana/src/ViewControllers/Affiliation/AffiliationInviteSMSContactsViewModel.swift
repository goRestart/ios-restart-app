import LGComponents

final class AffiliationInviteSMSContactsViewModel: BaseViewModel {
    var navigator: AffiliationInviteSMSContactsNavigator?

    override func backButtonPressed() -> Bool {
        navigator?.closeAffiliationInviteSMSContacts()
        return true
    }
}

