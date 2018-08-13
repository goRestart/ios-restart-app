final class ChangePasswordStandardRouter: ChangePasswordRouter {
    private weak var root: UINavigationController?
    
    init(root: UINavigationController) {
        self.root = root
    }
    
    func closeChangePassword() {
        root?.popViewController(animated: true)
    }
}
