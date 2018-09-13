final class RewardsInviteFriendsStandardWireframe: RewardsInviteFriendsNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeRewardsInviteFriends() {
        navigationController.popViewController(animated: true)
    }
}
