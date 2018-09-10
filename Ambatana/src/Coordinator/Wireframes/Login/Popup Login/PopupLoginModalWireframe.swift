final class PopupLoginModalWireframe: LoginModalWireframe {
    override
    func showLoginWithEmail(source: EventParameterLoginSourceValue,
                            loginAction: (() -> ())?,
                            cancelAction: (() -> ())?) {
        let vc = LoginBuilder.modal.buildLogInWithEmail(
            withSource: source,
            loginAction: loginAction,
            cancelAction: cancelAction
        )
        controller.modalTransitionStyle = .crossDissolve
        controller.present(vc, animated: true)
    }
    
    override
    func showSignInWithEmail(source: EventParameterLoginSourceValue,
                              appearance: LoginAppearance,
                              loginAction: (() -> ())?,
                              cancelAction: (() -> ())?) {
        let vc = LoginBuilder.modal.buildSignUpWithEmail(
            withSource: source,
            appearance: appearance,
            keyboardFocus: true,
            loginAction: loginAction,
            cancelAction: cancelAction
        )
        vc.modalTransitionStyle = .crossDissolve
        controller.present(vc, animated: true)
    }
}
