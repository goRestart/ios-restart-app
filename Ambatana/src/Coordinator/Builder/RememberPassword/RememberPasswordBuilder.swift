protocol RememberPasswordAssembly {
    func buildRememberPassword(withSource source: EventParameterLoginSourceValue, andEmail email: String?) -> UIViewController
}

enum RememberPasswordBuilder {
    case standard(UINavigationController)
}

extension RememberPasswordBuilder: RememberPasswordAssembly {
    
    func buildRememberPassword(withSource source: EventParameterLoginSourceValue, andEmail email: String?) -> UIViewController {
        let vm = RememberPasswordViewModel(source: source, email: email)
        let vc = RememberPasswordViewController(viewModel: vm, appearance: .light)
        switch self {
        case .standard(let nav):
            vm.router = RememberPasswordWireframe(root: nav)
        }
        return vc
    }
}

