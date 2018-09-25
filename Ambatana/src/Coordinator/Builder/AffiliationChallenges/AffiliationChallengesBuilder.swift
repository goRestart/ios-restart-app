import LGComponents

protocol AffiliationChallengesAssembly {
    func buildAffiliationChallenges(source: AffiliationChallengesSource) -> AffiliationChallengesViewController
}

enum AffiliationChallengesBuilder: AffiliationChallengesAssembly {
    case standard(UINavigationController)

    func buildAffiliationChallenges(source: AffiliationChallengesSource) -> AffiliationChallengesViewController {
        switch self {
        case .standard(let navigationController):
            let viewModel = AffiliationChallengesViewModel(source: source)
            viewModel.navigator = AffiliationChallengesStandardWireframe(navigationController: navigationController)
            let viewController = AffiliationChallengesViewController(viewModel: viewModel)
            return viewController
        }
    }
}
