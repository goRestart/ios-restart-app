final class ChangePasswordStandardWireframe: ChangePasswordNavigator {

    private let root: UINavigationController

    init(root: UINavigationController) {
        self.root = root
    }
    
    func closeChangePassword() {
        root.popViewController(animated: true)
    }
}
