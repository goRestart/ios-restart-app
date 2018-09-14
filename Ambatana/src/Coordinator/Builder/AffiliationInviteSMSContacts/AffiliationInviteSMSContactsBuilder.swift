import LGComponents

protocol AffiliationInviteSMSContactsAssembly {
    func buildAffiliationInviteSMSContacts() -> AffiliationInviteSMSContactsViewController
}

enum AffiliationInviteSMSContactsBuilder: AffiliationInviteSMSContactsAssembly {
    case standard(UINavigationController)

    func buildAffiliationInviteSMSContacts() -> AffiliationInviteSMSContactsViewController {
        switch self {
        case .standard(let navigationController):
            let viewModel = AffiliationInviteSMSContactsViewModel()
            viewModel.navigator = AffiliationInviteSMSContactsStandardWireframe(navigationController: navigationController)
            let viewController = AffiliationInviteSMSContactsViewController(viewModel: viewModel)
            return viewController
        }
    }
}

