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

protocol MainSignUpViewModelDelegate: class {
    func viewModelDidStartLoggingWithFB(viewModel: MainSignUpViewModel)
    func viewModel(viewModel: MainSignUpViewModel, didFinishLoggingWithFBWithResult result: FBLoginResult)

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
        delegate?.viewModelDidStartLoggingWithFB(self)
        FBLoginHelper.logInWithFacebook(sessionManager, tracker: TrackerProxy.sharedInstance, loginSource: loginSource){
            [weak self] (result: FBLoginResult) -> () in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.viewModel(strongSelf, didFinishLoggingWithFBWithResult: result)
        }
    }

    public func abandon() {
        let trackerEvent = TrackerEvent.loginAbandon(loginSource)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func loginWithFBFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginError(error))
    }

}
