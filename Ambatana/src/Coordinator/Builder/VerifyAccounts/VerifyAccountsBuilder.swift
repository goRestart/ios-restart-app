protocol VerifyAccountsAssembly {
    func buildVerifyAccounts(_ types: [VerificationType],
                             source: VerifyAccountsSource,
                             completionBlock: (() -> Void)?) -> UIViewController
}

enum VerifyAccountsBuilder {
    case modal
}

extension VerifyAccountsBuilder: VerifyAccountsAssembly {
    func buildVerifyAccounts(_ types: [VerificationType],
                             source: VerifyAccountsSource,
                             completionBlock: (() -> Void)?) -> UIViewController {
        let vm = VerifyAccountsViewModel(verificationTypes: types, source: source, completionBlock: completionBlock)
        let vc = VerifyAccountsViewController(viewModel: vm)
        switch self {
        case .modal:
            vc.setupForModalWithNonOpaqueBackground()
            vc.modalTransitionStyle = .crossDissolve
        }
        return vc
    }
}
