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
    func closeMainSignUpSuccessful(with myUser: MyUser)
    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func openSignUpEmailFromMainSignUp(collapsedEmailParam: EventParameterBoolean?)
    func openLogInEmailFromMainSignUp(collapsedEmailParam: EventParameterBoolean?)

    func openHelpFromMainSignUp()
    func open(url: URL)
}

protocol SignUpLogInNavigator: class {
    func cancelSignUpLogIn()
    func closeSignUpLogInSuccessful(with myUser: MyUser)
    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func openRecaptcha(transparentMode: Bool)

    func openRememberPasswordFromSignUpLogIn(email: String?)
    func openHelpFromSignUpLogin()
    func open(url: URL)
}

protocol RememberPasswordNavigator: class {
    func closeRememberPassword()
}

protocol LogInEmailNavigator: class {
    func cancelLogInEmail()
    func openHelpFromLogInEmail()
    func openRememberPasswordFromLogInEmail(email: String?)
    func openSignUpEmailFromLogInEmail(email: String?,
                                       isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?)
    func openScammerAlertFromLogInEmail(contactURL: URL)
    func closeAfterLogInSuccessful()
}

protocol SignUpEmailStep1Navigator: class {
    func cancelSignUpEmailStep1()
    func openHelpFromSignUpEmailStep1()
    func openNextStepFromSignUpEmailStep1(email: String, password: String,
                                          isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?)
    func openLogInFromSignUpEmailStep1(email: String?,
                                       isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?)
}

protocol SignUpEmailStep2Navigator: class {
    func openHelpFromSignUpEmailStep2()
    func openRecaptchaFromSignUpEmailStep2(transparentMode: Bool)
    func openScammerAlertFromSignUpEmailStep2(contactURL: URL)
    func closeAfterSignUpSuccessful()
}