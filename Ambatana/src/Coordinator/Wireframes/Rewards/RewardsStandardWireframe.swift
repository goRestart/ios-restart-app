final class RewardsStandardWireframe: RewardsNavigator {
    private let navigationController: UINavigationController
    private let rewardsInviteFriendsAssembly: RewardsInviteFriendsAssembly

    convenience init(navigationController: UINavigationController) {
        let rewardsInviteFriendsAssembly = RewardsInviteFriendsBuilder.standard(navigationController)
        self.init(navigationController: navigationController,
                  rewardsInviteFriendsAssembly: rewardsInviteFriendsAssembly)
    }

    init(navigationController: UINavigationController,
         rewardsInviteFriendsAssembly: RewardsInviteFriendsAssembly) {
        self.navigationController = navigationController
        self.rewardsInviteFriendsAssembly = rewardsInviteFriendsAssembly
    }

    func closeRewards() {
        navigationController.popViewController(animated: true)
    }

    func openRewardsInviteFriends() {
        let viewController = rewardsInviteFriendsAssembly.buildRewardsInviteFriends()
        navigationController.pushViewController(viewController, animated: true)
    }

    func openRewardsFAQ() {
        let viewController = rewardsInviteFriendsAssembly.buildRewardsFAQ()
        navigationController.pushViewController(viewController, animated: true)
    }
}
