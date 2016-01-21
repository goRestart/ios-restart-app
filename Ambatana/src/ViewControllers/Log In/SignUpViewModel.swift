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

protocol SignUpViewModelDelegate: class {
    func viewModelDidStartLoggingWithFB(viewModel: SignUpViewModel)
    func viewModeldidFinishLoginInWithFB(viewModel: SignUpViewModel)
    func viewModeldidCancelLoginInWithFB(viewModel: SignUpViewModel)
    func viewModel(viewModel: SignUpViewModel, didFailLoginInWithFB message: String)
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
            textColor: StyleHelper.termsConditionsBasecolor)
        attributtedLegalText.addAttribute(NSFontAttributeName, value: StyleHelper.termsConditionsSmallFont,
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

    weak var delegate: SignUpViewModelDelegate?
    
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
        FBLoginHelper.logInWithFacebook(sessionManager, tracker: TrackerProxy.sharedInstance, loginSource: loginSource,
            managerStart: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelDidStartLoggingWithFB(strongSelf)
            },
            completion: { [weak self] result in
                self?.processLoginWithFBResult(result)
            }
        )
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

    private func processLoginWithFBResult(result: FBLoginResult) {
        switch result {
        case .Success:
            delegate?.viewModeldidFinishLoginInWithFB(self)
        case .Cancelled:
            delegate?.viewModeldidCancelLoginInWithFB(self)
        case .Network:
            delegate?.viewModel(self, didFailLoginInWithFB: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginWithFBFailedWithError(.Network)
        case .Forbidden:
            delegate?.viewModel(self, didFailLoginInWithFB: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginWithFBFailedWithError(.Forbidden)
        case .NotFound:
            delegate?.viewModel(self, didFailLoginInWithFB: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginWithFBFailedWithError(.UserNotFoundOrWrongPassword)
        case .AlreadyExists:
            delegate?.viewModel(self, didFailLoginInWithFB: LGLocalizedString.mainSignUpFbConnectErrorEmailTaken)
            loginWithFBFailedWithError(.EmailTaken)
        case .Internal:
            delegate?.viewModel(self, didFailLoginInWithFB: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginWithFBFailedWithError(.Internal)
        }
    }

    private func loginWithFBFailedWithError(error: EventParameterLoginError) {
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.loginError(error))
    }
}
