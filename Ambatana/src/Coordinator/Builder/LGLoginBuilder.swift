protocol LoginAssembly {
    func buildMainSignIn(withSource: EventParameterLoginSourceValue,
                         loginAction: (()->())?,
                         cancelAction: (()->())?) -> MainSignUpViewController
    func buildLogInWithEmail(withSource: EventParameterLoginSourceValue,
                             loginAction: (()->())?,
                             cancelAction: (()->())?) -> SignUpLogInViewController
    func buildSignUpWithEmail(withSource: EventParameterLoginSourceValue,
                              appearance: LoginAppearance,
                              keyboardFocus: Bool,
                              loginAction: (()->())?,
                              cancelAction: (()->())?) -> SignUpLogInViewController
    func buildPopupSignUp(withMessage message: String,
                          andSource source: EventParameterLoginSourceValue,
                          appearance: LoginAppearance,
                          loginAction: (()->())?,
                          cancelAction: (()->())?) -> PopupSignUpViewController
}

enum LoginBuilder {
    case standard(context: UINavigationController)
    case modal
}

extension LoginBuilder: LoginAssembly {
    func buildMainSignIn(
        withSource source: EventParameterLoginSourceValue,
        loginAction: (()->())?,
        cancelAction: (()->())?
        ) -> MainSignUpViewController {
        let vm = SignUpViewModel(appearance: .light,
                                 source: source,
                                 loginAction: loginAction,
                                 cancelAction: cancelAction)
        let vc = MainSignUpViewController(viewModel: vm)
        switch self {
        case .standard(let context):
            vm.router = LoginStandardWireframe(nc: context)
        case .modal:
            vm.router = LoginModalWireframe(controller: vc)
        }
        return vc
    }
    
    func buildLogInWithEmail(
        withSource source: EventParameterLoginSourceValue,
        loginAction: (()->())?,
        cancelAction: (()->())?
        ) -> SignUpLogInViewController {
        let vm = SignUpLogInViewModel(source: source,
                                      action: .login,
                                      loginAction: loginAction,
                                      cancelAction: cancelAction)
        let vc = SignUpLogInViewController(
            viewModel: vm,
            appearance: .light,
            keyboardFocus: false
        )
        switch self {
        case .standard(let context):
            vm.router = LoginStandardWireframe(nc: context)
        case .modal:
            vm.router = LoginModalWireframe(controller: vc)
        }
        return vc
    }
    
    func buildSignUpWithEmail(
        withSource source: EventParameterLoginSourceValue,
        appearance: LoginAppearance,
        keyboardFocus: Bool = false,
        loginAction: (()->())?,
        cancelAction: (()->())?) -> SignUpLogInViewController {
        let vm = SignUpLogInViewModel(source: source,
                                      action: .signup,
                                      loginAction: loginAction,
                                      cancelAction: cancelAction)
        let vc = SignUpLogInViewController(
            viewModel: vm,
            appearance: appearance,
            keyboardFocus: keyboardFocus
        )
        switch self {
        case .standard(let context):
            vm.router = LoginStandardWireframe(nc: context)
        case .modal:
            vm.router = LoginModalWireframe(controller: vc)
        }
        return vc
    }
    
    func buildPopupSignUp(withMessage message: String,
                          andSource source: EventParameterLoginSourceValue,
                          appearance: LoginAppearance = .light,
                          loginAction: (()->())?,
                          cancelAction: (()->())?) -> PopupSignUpViewController {
        let vm = SignUpViewModel(appearance: appearance,
                                 source: source,
                                 loginAction: loginAction,
                                 cancelAction: cancelAction)
        let vc = PopupSignUpViewController(viewModel: vm,
                                           topMessage: message)
        switch self {
        case .standard(let context):
            vm.router = LoginStandardWireframe(nc: context)
        case .modal:
            vm.router = PopupLoginModalWireframe(controller: vc)
        }
        return vc
    }
}
