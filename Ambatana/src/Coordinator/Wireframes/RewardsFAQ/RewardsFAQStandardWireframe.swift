final class RewardsFAQStandardWireframe: RewardsFAQNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeRewardsFAQ() {
        navigationController.popViewController(animated: true)
    }
}
