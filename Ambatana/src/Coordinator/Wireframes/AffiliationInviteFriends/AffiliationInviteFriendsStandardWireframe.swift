import LGComponents

final class AffiliationInviteFriendsStandardWireframe: AffiliationInviteFriendsNavigator {
    private weak var navigationController: UINavigationController?
    private let affiliationInviteSMSContactsAssembly: AffiliationInviteSMSContactsAssembly

    convenience init(navigationController: UINavigationController) {
        let affiliationInviteSMSContactsAssembly = AffiliationInviteSMSContactsBuilder.standard(navigationController)
        self.init(navigationController: navigationController,
                  affiliationInviteSMSContactsAssembly: affiliationInviteSMSContactsAssembly)
    }

    init(navigationController: UINavigationController,
         affiliationInviteSMSContactsAssembly: AffiliationInviteSMSContactsAssembly) {
        self.navigationController = navigationController
        self.affiliationInviteSMSContactsAssembly = affiliationInviteSMSContactsAssembly
    }

    func closeAffiliationInviteFriends() {
        navigationController?.popViewController(animated: true)
    }

    func openAffiliationInviteSMSContacts() {
        let viewController = affiliationInviteSMSContactsAssembly.buildAffiliationInviteSMSContacts()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func openInviteTerms() {
        guard let navigationController = navigationController else { return }
        let assembly = AffiliationFAQBuilder.standard(navigationController)
        let vc = assembly.buildAffiliationFAQ()
        navigationController.pushViewController(vc, animated: true)
    }
}
