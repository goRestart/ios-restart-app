import LGComponents

final class AffiliationInviteFriendsStandardWireframe: AffiliationInviteFriendsNavigator {
    private let navigationController: UINavigationController
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
        navigationController.popViewController(animated: true)
    }

    func openAffiliationInviteSMSContacts() {
        let viewController = affiliationInviteSMSContactsAssembly.buildAffiliationInviteSMSContacts()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func openInviteTerms() {
        guard let termsURL = LetgoURLHelper.buildAffiliationFAQS() else { return }
        navigationController.openInAppWebViewWith(url: termsURL)
    }
}
