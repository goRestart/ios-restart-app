//
//  ChangePasswordViewModel.swift
//  LetGo
//
//  Created by Dídac on 30/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import Result

public protocol ChangePasswordViewModelDelegate : class {
    func viewModel(viewModel: ChangePasswordViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModel(viewModel: ChangePasswordViewModel, didFailValidationWithError error: UserSaveServiceError)
    func viewModelDidStartSendingPassword(viewModel: ChangePasswordViewModel)
    func viewModel(viewModel: ChangePasswordViewModel, didFinishSendingPasswordWithResult result: Result<User, UserSaveServiceError>)
    
}

public class ChangePasswordViewModel: BaseViewModel {
   
    weak var delegate : ChangePasswordViewModelDelegate?
    
    public var password: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: enableSaveButton())
        }
    }

    public var confirmPassword: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: enableSaveButton())
        }
    }

    override init() {
        self.password = ""
        self.confirmPassword = ""
        super.init()
    }
    
    
    // MARK: - public methods
        
    public func changePassword() {
        // check if username is ok (func in extension?)
        if isValidCombination() && isValidPassword() {
            
            delegate?.viewModelDidStartSendingPassword(self)
            
            MyUserManager.sharedInstance.updatePassword(password) { [weak self] (result: Result<User, UserSaveServiceError>) in
                if let strongSelf = self {
                    // Success
                    if let actualDelegate = strongSelf.delegate {
                        if let password = result.value {
                            actualDelegate.viewModel(strongSelf, didFinishSendingPasswordWithResult: result)
                        }
                            // Error
                        else {
                            actualDelegate.viewModel(strongSelf, didFinishSendingPasswordWithResult: result)
                        }
                    }
                }
            }
        }
        else if !isValidPassword() {
            delegate?.viewModel(self, didFailValidationWithError:UserSaveServiceError.InvalidPassword)
        } else {
            delegate?.viewModel(self, didFailValidationWithError:UserSaveServiceError.PasswordMismatch)
        }
        
    }
    
    public func isValidCombination() -> Bool {
        if password != confirmPassword { // passwords do not match.
            return false
        }
        return true
    }
    
    public func isValidPassword() -> Bool {
        if count(password) < Constants.passwordMinLength || count(confirmPassword) < Constants.passwordMinLength { // min length not fulfilled
            return false
        }
        return true
    }
    
    // MARK: - private methods
    
    func enableSaveButton() -> Bool {
        return !password.isEmpty && !confirmPassword.isEmpty
    }
    
}
