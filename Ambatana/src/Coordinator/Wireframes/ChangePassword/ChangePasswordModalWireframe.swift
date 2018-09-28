final class ChangePasswordModalWireframe: ChangePasswordNavigator {

    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }
    
    func closeChangePassword() {
        root.dismiss(animated: true, completion: nil)
    }
}
