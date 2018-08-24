final class PopupLoginModalWireframe: LoginModalWireframe {
    override
    func showLoginWithEmail(source: EventParameterLoginSourceValue,
                            logicAction: (() -> ())?,
                            cancelAction: (() -> ())?) {
        let vc = LoginBuilder.modal.buildLogInWithEmail(
            withSource: source,
            loginAction: logicAction,
            cancelAction: cancelAction
        )
        controller.modalTransitionStyle = .crossDissolve
        controller.present(vc, animated: true)
    }
    
    override
    func showSignInWithEmail(source: EventParameterLoginSourceValue,
                              appearance: LoginAppearance,
                              logicAction: (() -> ())?,
                              cancelAction: (() -> ())?) {
        let vc = LoginBuilder.modal.buildSignUpWithEmail(
            withSource: source,
            appearance: appearance,
            keyboardFocus: true,
            loginAction: logicAction,
            cancelAction: cancelAction
        )
        vc.modalTransitionStyle = .crossDissolve
        controller.present(vc, animated: true)
    }
}
