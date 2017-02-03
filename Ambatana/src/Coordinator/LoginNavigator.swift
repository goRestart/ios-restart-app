//
//  LoginNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

protocol MainSignUpNavigator: class {
    func cancelMainSignUp()
    func closeMainSignUp(myUser: MyUser)
    func closeMainSignUpAndOpenScammerAlert(network: EventParameterAccountNetwork)
    func openSignUpEmailFromMainSignUp(collapsedEmailParam: EventParameterCollapsedEmailField?)
    func openLogInEmailFromMainSignUp(collapsedEmailParam: EventParameterCollapsedEmailField?)

    func openHelpFromMainSignUp()
    func openTermsAndConditionsFromMainSignUp()
    func openPrivacyPolicyFromMainSignUp()
}

protocol SignUpLogInNavigator: class {
    func cancelSignUpLogIn()
    func closeSignUpLogIn(myUser: MyUser)
    func closeSignUpLogInAndOpenScammerAlert(network: EventParameterAccountNetwork)
    func openRecaptcha(transparentMode: Bool)

    func openRememberPasswordFromSignUpLogIn(email: String)
    func openHelpFromSignUpLogin()
    func openTermsAndConditionsFromSignUpLogin()
    func openPrivacyPolicyFromSignUpLogin()
}

protocol RememberPasswordNavigator: class {
    func closeRememberPassword()
}
