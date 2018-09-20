typealias AffiliationChallengesOpenSell = () -> ()

final class AffiliationChallengesStandardWireframe: AffiliationChallengesNavigator {
    private let navigationController: UINavigationController
    private let affiliationStoreAssembly: AffiliationStoreAssembly
    private let affiliationInviteFriendsAssembly: AffiliationInviteFriendsAssembly
    private let affiliationFAQAssembly: AffiliationFAQAssembly
    private let userVerificationAssembly: UserVerificationAssembly
    private let deepLinkMailBox: DeepLinkMailBox

    convenience init(navigationController: UINavigationController) {
        let deepLinkMailBox = LGDeepLinkMailBox.sharedInstance
        let affiliationStoreAssembly = AffiliationStoreBuilder.standard(navigationController)
        let affiliationInviteFriendsAssembly = AffiliationInviteFriendsBuilder.standard(navigationController)
        let affiliationFAQAssembly = AffiliationFAQBuilder.standard(navigationController)
        let userVerificationAssembly = LGUserVerificationBuilder.standard(nav: navigationController)
        self.init(navigationController: navigationController,
                  deepLinkMailBox: deepLinkMailBox,
                  affiliationStoreAssembly: affiliationStoreAssembly,
                  affiliationInviteFriendsAssembly: affiliationInviteFriendsAssembly,
                  affiliationFAQAssembly: affiliationFAQAssembly,
                  userVerificationAssembly: userVerificationAssembly)
    }

    init(navigationController: UINavigationController,
         deepLinkMailBox: DeepLinkMailBox,
         affiliationStoreAssembly: AffiliationStoreAssembly,
         affiliationInviteFriendsAssembly: AffiliationInviteFriendsAssembly,
         affiliationFAQAssembly: AffiliationFAQAssembly,
         userVerificationAssembly: UserVerificationAssembly) {
        self.navigationController = navigationController
        self.deepLinkMailBox = deepLinkMailBox
        self.affiliationStoreAssembly = affiliationStoreAssembly
        self.affiliationInviteFriendsAssembly = affiliationInviteFriendsAssembly
        self.affiliationFAQAssembly = affiliationFAQAssembly
        self.userVerificationAssembly = userVerificationAssembly
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
        let viewController = userVerificationAssembly.buildPhoneNumberVerification(editing: false)
        navigationController.pushViewController(viewController, animated: true)
    }

    func openPostListing() {
        guard let url = URL.makeSellDeeplink(with: .rewardCenter,
                                             category: nil,
                                             title: nil) else { return }
        deepLinkMailBox.push(convertible: url)
    }
}
