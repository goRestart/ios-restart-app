//
//  MainSignUpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit

import LGCoreKit
import Parse
import Result

public protocol MainSignUpViewModelDelegate: class {
    func viewModelDidStartLoggingWithFB(viewModel: MainSignUpViewModel)
    func viewModel(viewModel: MainSignUpViewModel, didFinishLoggingWithFBWithResult result: Result<User, UserLogInFBError>)
}

public class MainSignUpViewModel: BaseViewModel {
   
    // Delegate
    weak var delegate: MainSignUpViewModelDelegate?
    
    // Public methods
    
    public override init() {
        super.init()

        // Tracking
        TrackingHelper.trackEvent(.LoginVisit, parameters: nil)
    }
    
    public func logInWithFacebook() {
        // Notify the delegate about it started
        delegate?.viewModelDidStartLoggingWithFB(self)
        
        // Log in
        MyUserManager.sharedInstance.logInWithFacebook { [weak self] (result: Result<User, UserLogInFBError>) in
            if let strongSelf = self {

                // Tracking
                TrackingHelper.trackEvent(.LoginFB, parameters: nil)
                
                // Notify the delegate about it finished
                if let actualDelegate = strongSelf.delegate {
                    actualDelegate.viewModel(strongSelf, didFinishLoggingWithFBWithResult: result)
                }
            }
        }
    }
}
