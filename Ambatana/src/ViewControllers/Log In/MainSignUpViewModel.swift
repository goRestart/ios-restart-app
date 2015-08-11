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

public enum LoginSource: String {
    case Chats = "messages"
    case Sell = "posting"
    case Profile = "view-profile"
    
    case Favourite = "favourite"
    case MakeOffer = "offer"
    case AskQuestion = "question"
    case ReportFraud = "report-fraud"
}

public protocol MainSignUpViewModelDelegate: class {
    func viewModelDidStartLoggingWithFB(viewModel: MainSignUpViewModel)
    func viewModel(viewModel: MainSignUpViewModel, didFinishLoggingWithFBWithResult result: Result<User, UserLogInFBError>)
}

public class MainSignUpViewModel: BaseViewModel {
   
    // Login source
    let loginSource: EventParameterLoginSourceValue
    
    // Delegate
    weak var delegate: MainSignUpViewModelDelegate?
    
    // Public methods
    
    public init(source: EventParameterLoginSourceValue) {
        self.loginSource = source
        super.init()
        
        // Tracking
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginVisit(loginSource))
    }
    
    public func logInWithFacebook() {
        // Notify the delegate about it started
        delegate?.viewModelDidStartLoggingWithFB(self)
        
        // Log in
        MyUserManager.sharedInstance.logInWithFacebook { [weak self] (result: Result<User, UserLogInFBError>) in
            if let strongSelf = self {

                // Tracking
                if let user = result.value {
                    TrackerProxy.sharedInstance.setUser(user)
                }
                let trackerEvent = TrackerEvent.loginFB(strongSelf.loginSource)
                TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                
                // Notify the delegate about it finished
                if let actualDelegate = strongSelf.delegate {
                    actualDelegate.viewModel(strongSelf, didFinishLoggingWithFBWithResult: result)
                }
            }
        }
    }

    public func abandon() {
        // Tracking
        let trackerEvent = TrackerEvent.loginAbandon(loginSource)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
