final class AffiliationChallengesStandardWireframe: AffiliationChallengesNavigator {
    private let navigationController: UINavigationController
    private let affiliationInviteFriendsAssembly: AffiliationInviteFriendsAssembly

    convenience init(navigationController: UINavigationController) {
        let affiliationInviteFriendsAssembly = AffiliationInviteFriendsBuilder.standard(navigationController)
        self.init(navigationController: navigationController,
                  affiliationInviteFriendsAssembly: affiliationInviteFriendsAssembly)
    }

    init(navigationController: UINavigationController,
         affiliationInviteFriendsAssembly: AffiliationInviteFriendsAssembly) {
        self.navigationController = navigationController
        self.affiliationInviteFriendsAssembly = affiliationInviteFriendsAssembly
    }

    func closeAffiliationChallenges() {
        navigationController.popViewController(animated: true)
    }

    func openAffiliationInviteFriends() {
        let viewController = affiliationInviteFriendsAssembly.buildAffiliationInviteFriends()
        navigationController.pushViewController(viewController, animated: true)
    }

    func openAffiliationFAQ() {
        let viewController = affiliationInviteFriendsAssembly.buildAffiliationFAQ()
        navigationController.pushViewController(viewController, animated: true)
    }
}
