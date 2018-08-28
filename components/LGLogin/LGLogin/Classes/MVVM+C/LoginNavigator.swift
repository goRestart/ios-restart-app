//
//  LoginNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

public protocol MainSignUpNavigator: class {
    func cancelMainSignUp()
    func closeMainSignUpSuccessful(with myUser: MyUser)
    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func closeMainSignUpAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func openSignUpEmailFromMainSignUp(termsAndConditionsEnabled: Bool)
    func openLogInEmailFromMainSignUp(termsAndConditionsEnabled: Bool)

    func openHelpFromMainSignUp()
    func open(url: URL)
}

public protocol SignUpLogInNavigator: class {
    func cancelSignUpLogIn()
    func closeSignUpLogInSuccessful(with myUser: MyUser)
    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func closeSignUpLogInAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork)
    func openRecaptcha(action: LoginActionType)

    func openRememberPasswordFromSignUpLogIn(email: String?)
    func openHelpFromSignUpLogin()
    func open(url: URL)
}

public protocol RememberPasswordNavigator: class {
    func closeRememberPassword()
}
