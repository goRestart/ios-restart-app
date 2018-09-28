import LGComponents

protocol AffiliationFAQAssembly {
    func buildAffiliationFAQ() -> AffiliationFAQViewController
}

enum AffiliationFAQBuilder: AffiliationFAQAssembly {
    case standard(UINavigationController)

    func buildAffiliationFAQ() -> AffiliationFAQViewController {
        switch self {
        case .standard(let navigationController):
            let viewModel = AffiliationFAQViewModel()
            viewModel.navigator = AffiliationFAQStandardWireframe(navigationController: navigationController)
            let viewController = AffiliationFAQViewController(viewModel: viewModel)
            return viewController
        }
    }
}
