import LGComponents

protocol RewardsAssembly {
    func buildRewards() -> RewardsViewController
}

enum RewardsBuilder: RewardsAssembly {
    case standard(UINavigationController)

    func buildRewards() -> RewardsViewController {
        switch self {
        case .standard(let navigationController):
            let viewModel = RewardsViewModel()
            viewModel.navigator = RewardsStandardWireframe(navigationController: navigationController)
            let viewController = RewardsViewController(viewModel: viewModel)
            return viewController
        }
    }
}
