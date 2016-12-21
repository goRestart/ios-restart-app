//
//  ChangePasswordViewModel.swift
//  LetGo
//
//  Created by Dídac on 30/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Result

enum ChangePasswordError: ErrorType {
    case InvalidPassword
    case PasswordMismatch

    case Network
    case Internal
    case ResetPasswordLinkExpired

    init(repositoryError: RepositoryError, handleUnauthorizedAsLinkExpired: Bool) {
        switch repositoryError {
        case .Network:
            self = .Network
        case .Unauthorized:
            if handleUnauthorizedAsLinkExpired {
                self = .ResetPasswordLinkExpired
            } else {
                self = .Internal
            }
        case .Internal, .Forbidden, .TooManyRequests, .UserNotVerified, .ServerError, .NotFound:
            self = .Internal
        }
    }
}

protocol ChangePasswordViewModelDelegate: class {
    func viewModel(viewModel: ChangePasswordViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModel(viewModel: ChangePasswordViewModel, didFailValidationWithError error: ChangePasswordError)
    func viewModelDidStartSendingPassword(viewModel: ChangePasswordViewModel)
    func viewModel(viewModel: ChangePasswordViewModel, didFinishSendingPasswordWithResult
        result: Result<MyUser, ChangePasswordError>)
}

public class ChangePasswordViewModel: BaseViewModel {
   
    weak var delegate : ChangePasswordViewModelDelegate?
    weak var navigator: ChangePasswordNavigator?
    
    private let myUserRepository: MyUserRepository
    private var token: String?
    
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


    
    init(myUserRepository: MyUserRepository) {
        self.myUserRepository = myUserRepository
        self.password = ""
        self.confirmPassword = ""
        super.init()
    }
    
    override convenience init() {
        let myUserRepository = Core.myUserRepository
        self.init(myUserRepository: myUserRepository)
    }
    
    convenience init(token: String) {
        self.init()
        self.token = token
    }
    
    override func backButtonPressed() -> Bool {
        navigator?.closeChangePassword()
        return true
    }
    
    
    // MARK: - public methods
        
    public func changePassword() {
        // check if username is ok (func in extension?)
        if isValidCombination() && isValidPassword() {
            
            delegate?.viewModelDidStartSendingPassword(self)
            
            if let token = token {
                resetPassword(password, token: token)
            } else {
                updatePassword(password)
            }
        }
        else if !isValidPassword() {
            delegate?.viewModel(self, didFailValidationWithError: .InvalidPassword)
        } else {
            delegate?.viewModel(self, didFailValidationWithError: .PasswordMismatch)
        }
    }

    private func resetPassword(password: String, token: String) {
        myUserRepository.resetPassword(password, token: token) { [weak self] (updatePwdResult: (Result<MyUser, RepositoryError>)) in
            guard let strongSelf = self, delegate = strongSelf.delegate else { return }

            var result = Result<MyUser, ChangePasswordError>(error: .Internal)
            if let value = updatePwdResult.value {
                result = Result<MyUser, ChangePasswordError>(value: value)
            } else if let repositoryError = updatePwdResult.error {
                let error = ChangePasswordError(repositoryError: repositoryError, handleUnauthorizedAsLinkExpired: true)
                result = Result<MyUser, ChangePasswordError>(error: error)
            }
            delegate.viewModel(strongSelf, didFinishSendingPasswordWithResult: result)
        }
    }

    private func updatePassword(password: String) {
        myUserRepository.updatePassword(password) { [weak self] (updatePwdResult: (Result<MyUser, RepositoryError>)) in
            guard let strongSelf = self, delegate = strongSelf.delegate else { return }

            var result = Result<MyUser, ChangePasswordError>(error: .Internal)
            if let value = updatePwdResult.value {
                result = Result<MyUser, ChangePasswordError>(value: value)
            } else if let repositoryError = updatePwdResult.error {
                let error = ChangePasswordError(repositoryError: repositoryError, handleUnauthorizedAsLinkExpired: false)
                result = Result<MyUser, ChangePasswordError>(error: error)
            }
            delegate.viewModel(strongSelf, didFinishSendingPasswordWithResult: result)
        }
    }

    public func isValidCombination() -> Bool {
        if password != confirmPassword { // passwords do not match.
            return false
        }
        return true
    }
    
    public func isValidPassword() -> Bool {
        if password.characters.count < Constants.passwordMinLength ||
            password.characters.count > Constants.passwordMaxLength ||
            confirmPassword.characters.count < Constants.passwordMinLength ||
            confirmPassword.characters.count > Constants.passwordMaxLength { // min or max length not fulfilled
            return false
        }
        return true
    }

    
    public func passwordChangedCorrectly() {
        navigator?.closeChangePassword()
    }
    
    
    // MARK: - private methods
    
    func enableSaveButton() -> Bool {
        return !password.isEmpty && !confirmPassword.isEmpty
    }
    
}
