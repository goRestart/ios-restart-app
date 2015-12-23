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
import FBSDKLoginKit

public enum LoginSource: String {
    case Chats = "messages"
    case Sell = "posting"
    case Profile = "view-profile"
    
    case Favourite = "favourite"
    case MakeOffer = "offer"
    case AskQuestion = "question"
    case ReportFraud = "report-fraud"
}

enum FBLoginResult {
    case Success
    case Cancelled
    case Network
    case Forbidden
    case NotFound
    case Internal
}

protocol MainSignUpViewModelDelegate: class {
    func viewModelDidStartLoggingWithFB(viewModel: MainSignUpViewModel)
    func viewModel(viewModel: MainSignUpViewModel,
        didFinishLoggingWithFBWithResult result: FBLoginResult)

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

        let permissions = ["email", "public_profile", "user_friends", "user_birthday", "user_likes"]
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(permissions, fromViewController: nil) {
            [weak self] (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            guard let strongSelf = self else { return }

            if let _ = error {
                strongSelf.delegate?.viewModel(strongSelf, didFinishLoggingWithFBWithResult: .Internal)
            } else if result.isCancelled {
                strongSelf.delegate?.viewModel(strongSelf, didFinishLoggingWithFBWithResult: .Cancelled)
            } else if let token = result.token?.tokenString {

                strongSelf.delegate?.viewModelDidStartLoggingWithFB(strongSelf)

                strongSelf.sessionManager.loginFacebook(token) { [weak self] result in
                    guard let strongSelf = self else { return }

                    var modelResult: FBLoginResult
                    if let myUser = result.value {
                        TrackerProxy.sharedInstance.setUser(myUser)
                        let trackerEvent = TrackerEvent.loginFB(strongSelf.loginSource)
                        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

                        modelResult = .Success
                    } else if let error = result.error{
                        switch (error) {
                        case .Api(let apiError):
                            switch apiError {
                            case .Network:
                                modelResult = .Network
                            case .Scammer:
                                modelResult = .Forbidden
                            case .NotFound:
                                modelResult = .NotFound
                            case .Internal, .Unauthorized, .AlreadyExists, .InternalServerError:
                                modelResult = .Internal
                            }
                        case .Internal:
                            modelResult = .Internal
                        }
                    } else {
                        modelResult = .Internal
                    }
                    strongSelf.delegate?.viewModel(strongSelf, didFinishLoggingWithFBWithResult: modelResult)
                }
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
