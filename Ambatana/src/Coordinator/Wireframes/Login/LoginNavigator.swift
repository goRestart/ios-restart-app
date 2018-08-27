import LGComponents

protocol LoginNavigator {
    func close()
    func close(onFinish callback: (()->())?)
    func showHelp()
    func showSignInWithEmail(source: EventParameterLoginSourceValue,
                              appearance: LoginAppearance,
                              logicAction: (()->())?, cancelAction: (()->())?)
    func showLoginWithEmail(source: EventParameterLoginSourceValue,
                            logicAction: (()->())?, cancelAction: (()->())?)
    func showRememberPassword(source: EventParameterLoginSourceValue, email: String?)
    func showAlert(withTitle: String?, andBody: String, andType: AlertType, andActions: [UIAction])
    func open(url: URL)
    func showRecaptcha(action: LoginActionType, delegate: RecaptchaTokenDelegate)
    func showPasswordlessEmail()
    func showPasswordlessEmailSent(email: String)
}
