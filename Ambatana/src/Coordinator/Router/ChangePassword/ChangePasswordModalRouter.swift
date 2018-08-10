final class ChangePasswordModalRouter: ChangePasswordRouter {
    private weak var controller: UIViewController?
    
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    func closeChangePassword() {
        controller?.dismiss(animated: true, completion: nil)
    }
}
