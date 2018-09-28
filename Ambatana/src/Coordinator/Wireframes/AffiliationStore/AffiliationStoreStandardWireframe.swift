final class AffiliationStoreStandardWireframe: AffiliationStoreNavigator {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeAffiliationStore() {
        navigationController.popViewController(animated: true)
    }
}
