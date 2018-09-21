import Foundation

protocol PasswordlessUsernameAssembly {
    func buildPasswordlessUsernameView(token: String) -> PasswordlessUsernameViewController
}

enum PasswordlessUsernameBuilder {
    case modal(UIViewController)
}

extension PasswordlessUsernameBuilder: PasswordlessUsernameAssembly {
    func buildPasswordlessUsernameView(token: String) -> PasswordlessUsernameViewController {
        switch self {
        case .modal(let vc):
            let vm = PasswordlessUsernameViewModel(token: token)
            vm.navigator = PasswordlessUsernameWireframe(root: vc)
            return PasswordlessUsernameViewController(viewModel: vm)
        }
    }
}
