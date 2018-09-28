final class AffiliationFAQStandardWireframe: AffiliationFAQNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeAffiliationFAQ() {
        navigationController?.popViewController(animated: true)
    }
}
