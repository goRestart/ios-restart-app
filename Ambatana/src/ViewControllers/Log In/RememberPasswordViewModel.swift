//
//  RememberPasswordViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 15/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import Result

public protocol RememberPasswordViewModelDelegate: class {
    func viewModel(viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModelDidStartResettingPassword(viewModel: RememberPasswordViewModel)
    func viewModel(viewModel: RememberPasswordViewModel, didFinishResettingPasswordWithResult result: Result<Nil, UserPasswordResetServiceError>)
}


public class RememberPasswordViewModel: BaseViewModel {
   
    // Login source
    let loginSource: EventParameterLoginSourceValue
    
    // Delegate
    weak var delegate: RememberPasswordViewModelDelegate?
    
    // Input
    var email: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    
    // MARK: - Lifecycle
    
    init(source: EventParameterLoginSourceValue) {
        email = ""
        loginSource = source
        super.init()
    }
    
    // MARK: - Public methods
    
    public func resetPassword() {
        
        delegate?.viewModelDidStartResettingPassword(self)
        
        // Validation
        if !email.isEmail() {
            delegate?.viewModel(self, didFinishResettingPasswordWithResult: Result<Nil, UserPasswordResetServiceError>.failure(.InvalidEmail))
        }
        else {
            MyUserManager.sharedInstance.resetPassword(email.lowercaseString) { [weak self] (result: Result<Nil, UserPasswordResetServiceError>) in
                if let strongSelf = self, let actualDelegate = strongSelf.delegate {
                    
                    // Notify the delegate
                    actualDelegate.viewModel(strongSelf, didFinishResettingPasswordWithResult: result)
                    
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return count(email) > 0
    }
}
