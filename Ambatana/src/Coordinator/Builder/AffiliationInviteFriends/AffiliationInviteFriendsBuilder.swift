import LGComponents

protocol AffiliationInviteFriendsAssembly {
    func buildAffiliationInviteFriends() -> AffiliationInviteFriendsViewController
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
}
