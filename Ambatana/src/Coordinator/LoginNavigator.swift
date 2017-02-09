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
    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func openSignUpEmailFromMainSignUp(collapsedEmailParam: EventParameterCollapsedEmailField?)
    func openLogInEmailFromMainSignUp(collapsedEmailParam: EventParameterCollapsedEmailField?)

    func openHelpFromMainSignUp()
    func openURL(url: URL)
}

protocol SignUpLogInNavigator: class {
    func cancelSignUpLogIn()
    func closeSignUpLogIn(myUser: MyUser)
    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func openRecaptcha(transparentMode: Bool)

    func openRememberPasswordFromSignUpLogIn(email: String?)
    func openHelpFromSignUpLogin()
    func openURL(url: URL)
}

protocol RememberPasswordNavigator: class {
    func closeRememberPassword()
}
