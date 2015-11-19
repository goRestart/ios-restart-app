//
//  SignUpLoginViewModel.swift
//  LetGo
//
//  Created by Dídac on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

public protocol SignUpLogInViewModelDelegate: class {
    func viewModel(viewModel: SignUpLogInViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModelDidStartSigningUp(viewModel: SignUpLogInViewModel)
    func viewModel(viewModel: SignUpLogInViewModel, didFinishSigningUpWithResult result: UserSignUpServiceResult)
}

public class SignUpLogInViewModel: BaseViewModel {

    // Login source
    let loginSource: EventParameterLoginSourceValue
    
    // Delegate
    weak var delegate: SignUpLogInViewModelDelegate?
    
    // Action Type
    var actionType : LoginActionType
    
    // Input
    var username: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    var email: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    var password: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }

    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue, action: LoginActionType) {
        loginSource = source
        username = ""
        email = ""
        password = ""
        actionType = action
        super.init()
    }
    
    
    
    
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return username.characters.count > 0 && email.characters.count > 0 && password.characters.count > 0
    }
    
    private func usernameContainsLetgoString(theUsername: String) -> Bool {
        let lowerCaseUsername = theUsername.lowercaseString
        return lowerCaseUsername.rangeOfString("letgo") != nil ||
            lowerCaseUsername.rangeOfString("ietgo") != nil ||
            lowerCaseUsername.rangeOfString("letg0") != nil ||
            lowerCaseUsername.rangeOfString("ietg0") != nil ||
            lowerCaseUsername.rangeOfString("let go") != nil ||
            lowerCaseUsername.rangeOfString("iet go") != nil ||
            lowerCaseUsername.rangeOfString("let g0") != nil ||
            lowerCaseUsername.rangeOfString("iet g0") != nil
    }
    
}
