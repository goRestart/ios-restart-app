final class AffiliationInviteSMSContactsStandardWireframe: AffiliationInviteSMSContactsNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeAffiliationInviteSMSContacts() {
        navigationController?.popViewController(animated: true)
    }
}

