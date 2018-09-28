import LGComponents

final class LoginStandardWireframe: LoginNavigator {
    weak var nc: UINavigationController?
    
    init(nc: UINavigationController) {
        self.nc = nc
    }
    
    func showHelp() {
        guard let nc = nc else { return }

        let vc = LGHelpBuilder.standard(nc).buildHelp()
        nc.pushViewController(vc, animated: true)
    }
    
    func showSignInWithEmail(source: EventParameterLoginSourceValue,
                              appearance: LoginAppearance,
                              loginAction: (() -> ())?,
                              cancelAction: (() -> ())?) {
        guard let nc = nc else { return }
        let vc = LoginBuilder.standard(context: nc)
            .buildSignUpWithEmail(withSource: source,
                                  appearance: appearance,
                                  loginAction: loginAction,
                                  cancelAction: cancelAction)
        nc.pushViewController(vc, animated: true)
    }
    
    func showLoginWithEmail(source: EventParameterLoginSourceValue,
                            loginAction: (() -> ())?,
                            cancelAction: (() -> ())?) {
        guard let nc = nc else { return }
        let vc = LoginBuilder.standard(context: nc)
            .buildLogInWithEmail(withSource: source,
                                 loginAction: loginAction,
                                 cancelAction: cancelAction)
        nc.pushViewController(vc, animated: true)
    }
    
    func showRememberPassword(source: EventParameterLoginSourceValue, email: String?) {
        guard let nc = nc else { return }
        let vc = RememberPasswordBuilder.standard(nc)
            .buildRememberPassword(withSource: source, andEmail: email)
        nc.pushViewController(vc, animated: true)
    }
    
    func showAlert(withTitle title: String?,
                   andBody body: String,
                   andType type: AlertType,
                   andActions actions: [UIAction]) {
        nc?.showAlertWithTitle(
            title,
            text: body,
            alertType: type,
            buttonsLayout: .vertical,
            actions: actions
        )
    }
    
    func showRecaptcha(action: LoginActionType, delegate: RecaptchaTokenDelegate) {
        guard let nc = nc else { return }

        let vc = RecaptchaBuilder.modal(nc).buildRecaptcha(
            action: action, delegate: delegate)
        nc.present(vc, animated: true)
    }
    
    func open(url: URL) {
        nc?.openInAppWebViewWith(url: url)
    }

    func close() {
        nc?.popViewController(animated: true, completion: nil)
    }
    
    func close(onFinish callback: (()->())? = nil) {
        nc?.popViewController(animated: true)
        callback?()
    }

    func showPasswordlessEmail() {
        guard let nc = nc else { return }

        let vc = LoginBuilder.standard(context: nc).buildPasswordlessEmail()
        nc.pushViewController(vc, animated: true)
    }

    func showPasswordlessEmailSent(email: String) {
        let vc = LoginBuilder.modal.buildPasswordlesEmailSent(email: email)
        let nav = UINavigationController(rootViewController: vc)
        nc?.present(nav, animated: true)
    }
}
