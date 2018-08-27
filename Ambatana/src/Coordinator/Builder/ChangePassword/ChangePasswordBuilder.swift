import UIKit

protocol ChangePasswordAssembly {
    func buildChangePassword(withToken token: String) -> ChangePasswordViewController
}

enum ChangePasswordBuilder {
    case standard(root: UINavigationController)
    case modal
}

extension ChangePasswordBuilder: ChangePasswordAssembly {
    func buildChangePassword(withToken token: String) -> ChangePasswordViewController {
        let vm = ChangePasswordViewModel(token: token)
        let vc = ChangePasswordViewController(viewModel: vm)
        
        switch self {
        case .standard(let root):
            vm.router = ChangePasswordStandardWireframe(root: root)
        case .modal:
            vm.router = ChangePasswordModalWireframe(root: vc)
        }
        
        return vc
    }
    
    func buildChangePassword() -> UIViewController {
        let vm = ChangePasswordViewModel()
        let vc = ChangePasswordViewController(viewModel: vm)
        
        switch self {
        case .standard(let root):
            vm.router = ChangePasswordStandardWireframe(root: root)
            return vc
        case .modal:
            let nav = UINavigationController(rootViewController: vc)
            vm.router = ChangePasswordModalWireframe(root: vc)
            return nav
        }
    }
}
