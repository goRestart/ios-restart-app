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
    func viewModel(viewModel: MainSignUpViewModel,
        didFinishLoggingWithFBWithResult result: Result<MyUser, RepositoryError>)
}

public class MainSignUpViewModel: BaseViewModel {
   
    
    weak var delegate: MainSignUpViewModelDelegate?
    
    let sessionManager: SessionManager
    let loginSource: EventParameterLoginSourceValue
    
    // Public methods
    
    public init(sessionManager: SessionManager, source: EventParameterLoginSourceValue) {
        self.sessionManager = SessionManager.sharedInstance
        self.loginSource = source
        super.init()
        
        // Tracking
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginVisit(loginSource))
    }
    
    public convenience init(source: EventParameterLoginSourceValue) {
        let sessionManager = SessionManager.sharedInstance
        self.init(sessionManager: sessionManager, source: source)
    }
    
    public func logInWithFacebook() {
        // Notify the delegate about it started
        delegate?.viewModelDidStartLoggingWithFB(self)
        
        // Log in
        // TODO: ⛔️ Obtain FB token
        sessionManager.loginFacebook("") { [weak self] result in
            guard let strongSelf = self else { return }
            
            if let myUser = result.value {
                // Tracking
                TrackerProxy.sharedInstance.setUser(myUser)
                
                let trackerEvent = TrackerEvent.loginFB(strongSelf.loginSource)
                TrackerProxy.sharedInstance.trackEvent(trackerEvent)
            }
            
            // Notify the delegate about it finished
            if let delegate = strongSelf.delegate {
                delegate.viewModel(strongSelf, didFinishLoggingWithFBWithResult: result)
            }
        }
    }

    public func abandon() {
        // Tracking
        let trackerEvent = TrackerEvent.loginAbandon(loginSource)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func loginWithFBFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginError(error))
    }

}
