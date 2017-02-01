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
    func openSignUpEmailFromMainSignUp(source: EventParameterLoginSourceValue, collapsedEmailParam: EventParameterCollapsedEmailField?)
    func openLogInEmailFromMainSignUp(source: EventParameterLoginSourceValue, collapsedEmailParam: EventParameterCollapsedEmailField?)
}
