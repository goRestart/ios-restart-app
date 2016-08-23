//
//  AccessibilityId.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

/**
 Defines the accessibility identifiers used for automated UI testing. The format is the following:
    case <screen><element-name>
 
 i.e:
    case SignUpLoginEmailButton
 */
enum AccessibilityId: String {
    /** ABIOS-1554 */
    // ...

    /** ABIOS-1555 */
    // ...

    /** ABIOS-1556 */
    case MainSignUpFacebookButton
    case MainSignUpGoogleButton
    case MainSignUpSignupButton
    case MainSignupLogInButton
    case MainSignupCloseButton
    case MainSignupHelpButton

    case SignUpLoginFacebookButton
    case SignUpLoginGoogleButton
    case SignUpLoginEmailButton
    case SignUpLoginEmailTextField
    case SignUpLoginPasswordButton
    case SignUpLoginPasswordTextField
    case SignUpLoginUserNameButton
    case SignUpLoginUserNameTextField
    case SignUpLoginShowPasswordButton
    case SignUpLoginForgotPasswordButton
    case SignUpLoginSegmentedControl
    case SignUpLoginHelpButton
    case SignUpLoginCloseButton
    case SignUpLoginSendButton
    
    /** ABIOS-1557 */
    // ...
}

extension UIAccessibilityIdentification {
    var accessibilityId: AccessibilityId? {
        get {
            guard let accessibilityIdentifier = accessibilityIdentifier else { return nil }
            return AccessibilityId(rawValue: accessibilityIdentifier)
        }
        set {
            accessibilityIdentifier = newValue?.rawValue
        }
    }
}
