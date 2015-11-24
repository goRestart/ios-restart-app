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
    func viewModel(viewModel: RememberPasswordViewModel, didFinishResettingPasswordWithResult result: UserPasswordResetServiceResult)
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
    
    init(source: EventParameterLoginSourceValue, email: String) {
        self.email = email
        self.loginSource = source
        super.init()
    }
    
    // MARK: - Public methods
    
    public func resetPassword() {
        
        delegate?.viewModelDidStartResettingPassword(self)
        
        // Validation
        if !email.isEmail() {
            delegate?.viewModel(self, didFinishResettingPasswordWithResult: UserPasswordResetServiceResult(error: .InvalidEmail))
        }
        else {
            MyUserManager.sharedInstance.resetPassword(email) { [weak self] (result: UserPasswordResetServiceResult) in
                if let strongSelf = self, let actualDelegate = strongSelf.delegate {
                    
                    // Notify the delegate
                    actualDelegate.viewModel(strongSelf, didFinishResettingPasswordWithResult: result)
                    
                }
            }
        }
    }
    
    public func resetPasswordFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.passwordResetError(error.description))
    }
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return email.characters.count > 0
    }
}
