import LGComponents

protocol AffiliationChallengesAssembly {
    func buildAffiliationChallenges() -> AffiliationChallengesViewController
}

enum AffiliationChallengesBuilder: AffiliationChallengesAssembly {
    case standard(UINavigationController)

    func buildAffiliationChallenges() -> AffiliationChallengesViewController {
        switch self {
        case .standard(let navigationController):
            let viewModel = AffiliationChallengesViewModel()
            viewModel.navigator = AffiliationChallengesStandardWireframe(navigationController: navigationController)
            let viewController = AffiliationChallengesViewController(viewModel: viewModel)
            return viewController
        }
    }
}
