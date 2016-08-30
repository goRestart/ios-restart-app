//
//  MainSignUpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit
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

protocol SignUpViewModelDelegate: class {
    func viewModelDidStartLoggingIn(viewModel: SignUpViewModel)
    func viewModeldidFinishLoginIn(viewModel: SignUpViewModel)
    func viewModeldidCancelLoginIn(viewModel: SignUpViewModel)
    func viewModel(viewModel: SignUpViewModel, didFailLoginIn message: String)
}

public class SignUpViewModel: BaseViewModel {

    var attributedLegalText: NSAttributedString {
        guard let conditionsURL = termsAndConditionsURL, let privacyURL = privacyURL else {
            return NSAttributedString(string: LGLocalizedString.mainSignUpTermsConditions)
        }

        let links = [LGLocalizedString.mainSignUpTermsConditionsTermsPart: conditionsURL,
            LGLocalizedString.mainSignUpTermsConditionsPrivacyPart: privacyURL]
        let localizedLegalText = LGLocalizedString.mainSignUpTermsConditions
        let attributtedLegalText = localizedLegalText.attributedHyperlinkedStringWithURLDict(links,
            textColor: UIColor.darkGrayText)
        attributtedLegalText.addAttribute(NSFontAttributeName, value: UIFont.smallBodyFont,
            range: NSMakeRange(0, attributtedLegalText.length))
        return attributtedLegalText
    }

    private var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    private var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }

    private let sessionManager: SessionManager
    private let loginSource: EventParameterLoginSourceValue
    private let googleLoginHelper: GoogleLoginHelper

    weak var delegate: SignUpViewModelDelegate?
    
    // Public methods
    
    public init(sessionManager: SessionManager, source: EventParameterLoginSourceValue) {
        self.sessionManager = sessionManager
        self.loginSource = source
        self.googleLoginHelper = GoogleLoginHelper(loginSource: source)
        super.init()
        
        // Tracking
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginVisit(loginSource))
    }
    
    public convenience init(source: EventParameterLoginSourceValue) {
        let sessionManager = Core.sessionManager
        self.init(sessionManager: sessionManager, source: source)
    }
    
    public func logInWithFacebook() {
        FBLoginHelper.logInWithFacebook(sessionManager, tracker: TrackerProxy.sharedInstance, loginSource: loginSource,
            managerStart: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelDidStartLoggingIn(strongSelf)
            },
            completion: { [weak self] result in
                guard let error = self?.processAuthResult(result) else { return }
                self?.trackLoginFBFailedWithError(error)
            }
        )
    }

    public func logInWithGoogle() {
        googleLoginHelper.login({ [weak self] in
            // Google OAuth completed. Token obtained
            guard let strongSelf = self else { return }
            self?.delegate?.viewModelDidStartLoggingIn(strongSelf)
        }) { [weak self] result in
            // Login with Bouncer finished with success or fail
            guard let error = self?.processAuthResult(result) else { return }
            self?.trackLoginGoogleFailedWithError(error)
        }
    }

    public func abandon() {
        let trackerEvent = TrackerEvent.loginAbandon(loginSource)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    public func loginSignupViewModelForLogin() -> SignUpLogInViewModel {
        return SignUpLogInViewModel(source: loginSource, action: .Login)
    }

    public func loginSignupViewModelForSignUp() -> SignUpLogInViewModel {
        return SignUpLogInViewModel(source: loginSource, action: .Signup)
    }


    // MARK: - Private methods

    private func processAuthResult(result: ExternalServiceAuthResult) -> EventParameterLoginError? {
        var loginError: EventParameterLoginError? = nil
        switch result {
        case .Success:
            delegate?.viewModeldidFinishLoginIn(self)
        case .Cancelled:
            delegate?.viewModeldidCancelLoginIn(self)
        case .Network:
            delegate?.viewModel(self, didFailLoginIn: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .Network
        case .Forbidden:
            delegate?.viewModel(self, didFailLoginIn: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .Forbidden
        case .NotFound:
            delegate?.viewModel(self, didFailLoginIn: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .UserNotFoundOrWrongPassword
        case .Conflict(let cause):
            var message = ""
            switch cause {
            case .UserExists, .NotSpecified, .Other:
                message = LGLocalizedString.mainSignUpFbConnectErrorEmailTaken
            case .EmailRejected:
                message = LGLocalizedString.mainSignUpErrorUserRejected
            case .RequestAlreadyProcessed:
                message = LGLocalizedString.mainSignUpErrorRequestAlreadySent
            }
            delegate?.viewModel(self, didFailLoginIn: message)
            loginError = .EmailTaken
        case let .Internal(description):
            delegate?.viewModel(self, didFailLoginIn: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .Internal(description: description)
        }
        return loginError
    }

    private func trackLoginFBFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginFBError(error))
    }

    private func trackLoginGoogleFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginGoogleError(error))
    }
}
