import LGComponents

class LoginModalWireframe: LoginNavigator {
    let controller: UIViewController
    
    init(controller: UIViewController) {
        self.controller = controller
    }
    
    func showHelp() {
        guard let nc = controller.navigationController else { return }
        let vc = LGHelpBuilder.standard(nc).buildHelp()
        controller.navigationController?.pushViewController(vc, animated: true)
    }

    func showSignInWithEmail(source: EventParameterLoginSourceValue,
                              appearance: LoginAppearance,
                              loginAction: (()->())?, cancelAction: (()->())?) {
        guard let nc = controller.navigationController else { return }
        let vc = LoginBuilder.standard(context: nc)
            .buildSignUpWithEmail(withSource: source,
                                  appearance: appearance,
                                  loginAction: loginAction,
                                  cancelAction: cancelAction)
        nc.pushViewController(vc, animated: true)
    }

    func showLoginWithEmail(source: EventParameterLoginSourceValue,
                            loginAction: (()->())?, cancelAction: (()->())?) {
        guard let nc = controller.navigationController else { return }
        let vc = LoginBuilder.standard(context: nc)
            .buildLogInWithEmail(withSource: source,
                                 loginAction: loginAction,
                                 cancelAction: cancelAction)
        nc.pushViewController(vc, animated: true)
    }
    
    func showRememberPassword(source: EventParameterLoginSourceValue, email: String?) {
        guard let nc = controller.navigationController else { return }
        let vc = RememberPasswordBuilder.standard(nc).buildRememberPassword(
            withSource: source, andEmail: email)
        controller.pushViewController(vc, animated: true)
    }
  
    func showAlert(withTitle title: String?,
                   andBody body: String,
                   andType type: AlertType,
                   andActions actions: [UIAction]) {
        controller.showAlertWithTitle(
            title,
            text: body,
            alertType: type,
            buttonsLayout: .vertical,
            actions: actions
        )
    }
    
    func showRecaptcha(action: LoginActionType, delegate: RecaptchaTokenDelegate) {
        let vc = RecaptchaBuilder
            .modal(controller)
            .buildRecaptcha(action: action, delegate: delegate)
        controller.present(vc, animated: true)
    }
    
    func open(url: URL) {
        controller.openInAppWebViewWith(url: url)
    }

    func close() {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func close(onFinish callback: (()->())? = nil) {
        controller.dismiss(animated: true, completion: callback)
    }

    func showPasswordlessEmail() {
        guard let nc = controller.navigationController else { return }
        let vc = LoginBuilder.standard(context: nc).buildPasswordlessEmail()
        nc.pushViewController(vc, animated: true)
    }

    func showPasswordlessEmailSent(email: String) {
        let vc = LoginBuilder.modal.buildPasswordlesEmailSent(email: email)
        let nav = UINavigationController(rootViewController: vc)
        controller.present(nav, animated: true)
    }
}
