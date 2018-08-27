protocol RecaptchaAssembly {
    func buildRecaptcha(action: LoginActionType, delegate: RecaptchaTokenDelegate) -> UIViewController
}

enum RecaptchaBuilder {
    case modal(UIViewController)
}

extension RecaptchaBuilder: RecaptchaAssembly {
    func buildRecaptcha(action: LoginActionType, delegate: RecaptchaTokenDelegate) -> UIViewController {
        let vm = RecaptchaViewModel(action: action)
        vm.delegate = delegate
        let vc = RecaptchaViewController(viewModel: vm)
        switch self {
        case .modal(let root):
            vm.router = RecaptchaPasswordWireframe(root: root)
        }
        return vc
    }
}

