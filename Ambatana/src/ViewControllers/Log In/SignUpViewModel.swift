//
//  SignUpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Parse
import LGCoreKit

public protocol SignUpViewModelDelegate: class {
    func viewModel(viewModel: SignUpViewModel, updateSendButtonEnabledState enabled: Bool)
    func viewModelDidStartSigningUp(viewModel: SignUpViewModel)
    func viewModel(viewModel: SignUpViewModel, didFinishSigningUpWithResult result: SignUpViewModel.Result)
}

public class SignUpViewModel: BaseViewModel {
    
    // Constants & enums
    private static let minPasswordLength = 6
    
    public enum ResultCode {
        case InvalidEmail
        case InvalidUsername
        case InvalidPassword
        case ConnectionFailed
        case EmailTaken
        case InternalError
    }
    
    public  enum Result {
        case Success
        case Error(ResultCode)
    }
    
    // Delegate
    weak var delegate: SignUpViewModelDelegate?
    
    // Input
    var email: String {
        didSet {
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    var username: String {
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
    
    override init() {
        email = ""
        username = ""
        password = ""
        super.init()
    }
    
    // MARK: - Public methods
    
    public func signUp() {

        delegate?.viewModelDidStartSigningUp(self)
        
        // Validation
        if !email.isEmail() {
            delegate?.viewModel(self, didFinishSigningUpWithResult: .Error(.InvalidEmail))
        }
        else if count(username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())) < 1 {
            delegate?.viewModel(self, didFinishSigningUpWithResult: .Error(.InvalidUsername))
        }
        else if count(password) < SignUpViewModel.minPasswordLength {
            delegate?.viewModel(self, didFinishSigningUpWithResult: .Error(.InvalidPassword))
        }
        else {
            // TODO: Refactor this into LGCoreKit with error handling in there
            MyUserManager.sharedInstance.signUpWithEmail(email, password: password, publicUsername: username) { [weak self] (success: Bool, error: NSError?) in
                if let strongSelf = self, let actualDelegate = strongSelf.delegate {
                    if success {
                        actualDelegate.viewModel(strongSelf, didFinishSigningUpWithResult: .Success)
                    }
                    else if let actualError = error {
                        switch(actualError.code) {
                        case PFErrorCode.ErrorConnectionFailed.rawValue:
                            actualDelegate.viewModel(strongSelf, didFinishSigningUpWithResult: .Error(.ConnectionFailed))
                        case PFErrorCode.ErrorUsernameTaken.rawValue:
                            actualDelegate.viewModel(strongSelf, didFinishSigningUpWithResult: .Error(.EmailTaken))
                        case PFErrorCode.ErrorUserEmailTaken.rawValue:
                            actualDelegate.viewModel(strongSelf, didFinishSigningUpWithResult: .Error(.EmailTaken))
                        case LGErrorCode.Internal.rawValue:
                            actualDelegate.viewModel(strongSelf, didFinishSigningUpWithResult: .Error(.InternalError))
                        default:
                            actualDelegate.viewModel(strongSelf, didFinishSigningUpWithResult: .Error(.InternalError))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        //        PFErrorCode.ErrorConnectionFailed.rawValue
        
        return count(email) > 0 && count(username) > 0 && count(password) > 0
    }
}
