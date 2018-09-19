final class AffiliationChallengesStandardWireframe: AffiliationChallengesNavigator {
    private let navigationController: UINavigationController
    private let affiliationStoreAssembly: AffiliationStoreAssembly
    private let affiliationInviteFriendsAssembly: AffiliationInviteFriendsAssembly
    private let affiliationFAQAssembly: AffiliationFAQAssembly

    convenience init(navigationController: UINavigationController) {
        let affiliationStoreAssembly = AffiliationStoreBuilder.standard(navigationController)
        let affiliationInviteFriendsAssembly = AffiliationInviteFriendsBuilder.standard(navigationController)
        let affiliationFAQAssembly = AffiliationFAQBuilder.standard(navigationController)
        self.init(navigationController: navigationController,
                  affiliationStoreAssembly: affiliationStoreAssembly,
                  affiliationInviteFriendsAssembly: affiliationInviteFriendsAssembly,
                  affiliationFAQAssembly: affiliationFAQAssembly)
    }

    init(navigationController: UINavigationController,
         affiliationStoreAssembly: AffiliationStoreAssembly,
         affiliationInviteFriendsAssembly: AffiliationInviteFriendsAssembly,
         affiliationFAQAssembly: AffiliationFAQAssembly) {
        self.navigationController = navigationController
        self.affiliationStoreAssembly = affiliationStoreAssembly
        self.affiliationInviteFriendsAssembly = affiliationInviteFriendsAssembly
        self.affiliationFAQAssembly = affiliationFAQAssembly
    }

    func closeAffiliationChallenges() {
        navigationController.popViewController(animated: true)
    }

    func openAffiliationStore() {
        let viewController = affiliationStoreAssembly.buildAffiliationStore()
        navigationController.pushViewController(viewController, animated: true)
    }

    func openAffiliationInviteFriends() {
        let viewController = affiliationInviteFriendsAssembly.buildAffiliationInviteFriends()
        navigationController.pushViewController(viewController, animated: true)
    }

    func openAffiliationFAQ() {
        let viewController = affiliationFAQAssembly.buildAffiliationFAQ()
        navigationController.pushViewController(viewController, animated: true)
    }

    func openConfirmPhone() {

    }

    func openPostListing() {
        
    }
}
