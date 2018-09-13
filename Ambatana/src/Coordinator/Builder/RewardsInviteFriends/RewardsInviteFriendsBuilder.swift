import LGComponents

protocol RewardsInviteFriendsAssembly {
    func buildRewardsInviteFriends() -> RewardsInviteFriendsViewController
    func buildRewardsFAQ() -> RewardsFAQViewController
}

enum RewardsInviteFriendsBuilder: RewardsInviteFriendsAssembly {
    case standard(UINavigationController)

    func buildRewardsInviteFriends() -> RewardsInviteFriendsViewController {
        switch self {
        case .standard(let navigationController):
            let viewModel = RewardsInviteFriendsViewModel()
            viewModel.navigator = RewardsInviteFriendsStandardWireframe(navigationController: navigationController)
            let viewController = RewardsInviteFriendsViewController(viewModel: viewModel)
            return viewController
        }
    }

    func buildRewardsFAQ() -> RewardsFAQViewController {
        switch self {
        case .standard(let navigationController):
            let viewModel = RewardsFAQViewModel()
            viewModel.navigator = RewardsFAQStandardWireframe(navigationController: navigationController)
            let viewController = RewardsFAQViewController(viewModel: viewModel)
            return viewController
        }
    }
}
