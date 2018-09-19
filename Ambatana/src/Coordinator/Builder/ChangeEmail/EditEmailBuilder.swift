protocol EditEmailAssembly {
    func buildEditEmail() -> UIViewController
}

enum EditEmailBuilder {
    case standard(UINavigationController)
}

extension EditEmailBuilder: EditEmailAssembly {
    func buildEditEmail() -> UIViewController {
        let vm = ChangeEmailViewModel()
        let vc = ChangeEmailViewController(with: vm)
        switch self {
        case .standard(let nc):
            vm.navigator = EditEmailWireframe(nc: nc)
            return vc
        }
    }
}
