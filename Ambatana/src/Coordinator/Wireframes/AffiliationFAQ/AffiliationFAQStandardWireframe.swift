final class AffiliationFAQStandardWireframe: AffiliationFAQNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeAffiliationFAQ() {
        navigationController.popViewController(animated: true)
    }
}
