import UIKit

protocol ChangePasswordBuilder {
    func buildChangePassword(withToken token: String) -> UIViewController
    func buildChangePassword() -> UIViewController
}

enum LGChangePasswordBuilder {
    case standard(UINavigationController)
    case modal
}

extension LGChangePasswordBuilder: ChangePasswordBuilder {
    func buildChangePassword(withToken token: String) -> UIViewController {
        let vm = ChangePasswordViewModel(token: token)
        let vc = ChangePasswordViewController(viewModel: vm)
        
        switch self {
        case .standard(let root):
            vm.router = ChangePasswordStandardRouter(root: root)
        case .modal:
            vm.router = ChangePasswordModalRouter(controller: vc)
        }
        
        return vc
    }
    
    func buildChangePassword() -> UIViewController {
        let vm = ChangePasswordViewModel()
        let vc = ChangePasswordViewController(viewModel: vm)
        
        switch self {
        case .standard(let root):
            vm.router = ChangePasswordStandardRouter(root: root)
            return vc
        case .modal:
            let nav = UINavigationController(rootViewController: vc)
            vm.router = ChangePasswordModalRouter(controller: vc)
            return nav
        }
    }
}
