final class AffiliationInviteSMSContactsStandardWireframe: AffiliationInviteSMSContactsNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeAffiliationInviteSMSContacts() {
        navigationController.popViewController(animated: true)
    }
}

