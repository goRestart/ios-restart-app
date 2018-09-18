import LGComponents

protocol AffiliationInviteFriendsAssembly {
    func buildAffiliationInviteFriends() -> AffiliationInviteFriendsViewController
    func buildAffiliationFAQ() -> AffiliationFAQViewController
}

enum AffiliationInviteFriendsBuilder: AffiliationInviteFriendsAssembly {
    case standard(UINavigationController)

    func buildAffiliationInviteFriends() -> AffiliationInviteFriendsViewController {
        switch self {
        case .standard(let navigationController):
            let viewModel = AffiliationInviteFriendsViewModel()
            viewModel.navigator = AffiliationInviteFriendsStandardWireframe(navigationController: navigationController)
            let viewController = AffiliationInviteFriendsViewController(viewModel: viewModel)
            return viewController
        }
    }

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
