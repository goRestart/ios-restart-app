final class RewardsStandardWireframe: RewardsNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeRewards() {
        navigationController.popViewController(animated: true)
    }
}
