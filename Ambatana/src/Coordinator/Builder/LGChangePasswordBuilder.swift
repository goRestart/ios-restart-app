import UIKit

protocol ChangePasswordBuilder {
    func buildChangePassword(withToken token: String) -> ChangePasswordViewController
}

enum LGChangePasswordBuilder {
    case standard(root: UINavigationController)
    case modal
}

extension LGChangePasswordBuilder: ChangePasswordBuilder {
    func buildChangePassword(withToken token: String) -> ChangePasswordViewController {
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
    
    func buildChangePassword() -> ChangePasswordViewController {
        let vm = ChangePasswordViewModel()
        let vc = ChangePasswordViewController(viewModel: vm)
        
        switch self {
        case .standard(let root):
            vm.router = ChangePasswordStandardRouter(root: root)
        case .modal:
            vm.router = ChangePasswordModalRouter(controller: vc)
        }
        
        return vc
    }
}
