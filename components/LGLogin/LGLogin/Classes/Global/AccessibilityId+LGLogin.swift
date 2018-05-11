
extension AccessibilityId {
    
    enum LGLogin: String, Accessible {
        
        var identifier: String { return rawValue }
        
        // MainSignUp
        case mainSignUpFacebookButton
        case mainSignUpGoogleButton
        case mainSignUpSignupButton
        case mainSignupLogInButton
        case mainSignupCloseButton
        case mainSignupHelpButton
        
        // SignUpLogin
        case signUpLoginFacebookButton
        case signUpLoginGoogleButton
        case signUpLoginEmailButton
        case signUpLoginEmailTextField
        case signUpLoginPasswordButton
        case signUpLoginPasswordTextField
        case signUpLoginUserNameButton
        case signUpLoginUserNameTextField
        case signUpLoginShowPasswordButton
        case signUpLoginForgotPasswordButton
        case signUpLoginSegmentedControl
        case signUpLoginHelpButton
        case signUpLoginCloseButton
        case signUpLoginSendButton

        // Recaptcha
        case recaptchaCloseButton
        case recaptchaLoading
        case recaptchaWebView

        // ChangePassword
        case changePasswordPwdTextfield
        case changePasswordPwdConfirmTextfield
        case changePasswordSendButton

        // Help
        case helpWebView
    }
}

