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
import RxSwift

enum LoginSource: String {
    case Chats = "messages"
    case Sell = "posting"
    case Profile = "view-profile"
    
    case Favourite = "favourite"
    case MakeOffer = "offer"
    case AskQuestion = "question"
    case ReportFraud = "report-fraud"
}

enum LoginAppearance {
    case Dark, Light
}

protocol SignUpViewModelDelegate: class {
    func viewModelDidStartLoggingIn(viewModel: SignUpViewModel)
    func viewModeldidFinishLoginIn(viewModel: SignUpViewModel)
    func viewModeldidCancelLoginIn(viewModel: SignUpViewModel)
    func viewModel(viewModel: SignUpViewModel, didFailLoginIn message: String)
}

class SignUpViewModel: BaseViewModel {

    var attributedLegalText: NSAttributedString {
        guard let conditionsURL = termsAndConditionsURL, let privacyURL = privacyURL else {
            return NSAttributedString(string: LGLocalizedString.mainSignUpTermsConditions)
        }

        let links = [LGLocalizedString.mainSignUpTermsConditionsTermsPart: conditionsURL,
            LGLocalizedString.mainSignUpTermsConditionsPrivacyPart: privacyURL]
        let localizedLegalText = LGLocalizedString.mainSignUpTermsConditions
        let attributtedLegalText = localizedLegalText.attributedHyperlinkedStringWithURLDict(links,
            textColor: UIColor.darkGrayText)
        let range = NSMakeRange(0, attributtedLegalText.length)
        attributtedLegalText.addAttribute(NSFontAttributeName, value: UIFont.smallBodyFont, range: range)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        attributtedLegalText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
        return attributtedLegalText
    }

    private var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    private var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }

    private let sessionManager: SessionManager
    private let keyValueStorage: KeyValueStorage
    private let tracker: Tracker
    let appearance: LoginAppearance
    private let loginSource: EventParameterLoginSourceValue
    private let googleLoginHelper: GoogleLoginHelper

    let previousFacebookUsername: Variable<String?>
    let previousGoogleUsername: Variable<String?>

    weak var delegate: SignUpViewModelDelegate?


    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, keyValueStorage: KeyValueStorage, tracker: Tracker,
         appearance: LoginAppearance, source: EventParameterLoginSourceValue) {
        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage
        self.tracker = tracker
        self.appearance = appearance
        self.loginSource = source
        self.googleLoginHelper = GoogleLoginHelper(loginSource: source)
        self.previousFacebookUsername = Variable<String?>(nil)
        self.previousGoogleUsername = Variable<String?>(nil)
        super.init()

        updatePreviousEmailAndUsernamesFromKeyValueStorage()

        // Tracking
        tracker.trackEvent(TrackerEvent.loginVisit(loginSource))
    }
    
    convenience init(appearance: LoginAppearance, source: EventParameterLoginSourceValue) {
        let sessionManager = Core.sessionManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, keyValueStorage: keyValueStorage, tracker: tracker,
                  appearance: appearance, source: source)
    }


    // MARK: - Public methods

    func logInWithFacebook() {
        FBLoginHelper.logInWithFacebook(sessionManager, tracker: tracker, loginSource: loginSource,
            managerStart: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelDidStartLoggingIn(strongSelf)
            },
            completion: { [weak self] result in
                guard let error = self?.processAuthResult(result, accountProvider: .Facebook) else { return }
                self?.trackLoginFBFailedWithError(error)
            }
        )
    }

    func logInWithGoogle() {
        googleLoginHelper.login({ [weak self] in
            // Google OAuth completed. Token obtained
            guard let strongSelf = self else { return }
            self?.delegate?.viewModelDidStartLoggingIn(strongSelf)
        }) { [weak self] result in
            // Login with Bouncer finished with success or fail
            guard let error = self?.processAuthResult(result, accountProvider: .Google) else { return }
            self?.trackLoginGoogleFailedWithError(error)
        }
    }

    func abandon() {
        let trackerEvent = TrackerEvent.loginAbandon(loginSource)
        tracker.trackEvent(trackerEvent)
    }

    func loginSignupViewModelForLogin() -> SignUpLogInViewModel {
        return SignUpLogInViewModel(source: loginSource, action: .Login)
    }

    func loginSignupViewModelForSignUp() -> SignUpLogInViewModel {
        return SignUpLogInViewModel(source: loginSource, action: .Signup)
    }


    // MARK: - Private methods

    private func processAuthResult(result: ExternalServiceAuthResult,
                                   accountProvider: AccountProvider) -> EventParameterLoginError? {
        var loginError: EventParameterLoginError? = nil
        switch result {
        case let .Success(myUser):
            savePreviousEmailOrUsername(accountProvider, username: myUser.name)
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
        case .BadRequest:
            delegate?.viewModel(self, didFailLoginIn: LGLocalizedString.mainSignUpFbConnectErrorGeneric)
            loginError = .BadRequest
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
        tracker.trackEvent(TrackerEvent.loginFBError(error))
    }

    private func trackLoginGoogleFailedWithError(error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginGoogleError(error))
    }
}


// MARK: > Previous user name

private extension SignUpViewModel {
    private func updatePreviousEmailAndUsernamesFromKeyValueStorage() {
        guard let accountProviderString = keyValueStorage[.previousUserAccountProvider],
            accountProvider = AccountProvider(rawValue: accountProviderString) else { return }

        let username = keyValueStorage[.previousUserEmailOrName]
        updatePreviousEmailAndUsernames(accountProvider, username: username)
    }

    private func updatePreviousEmailAndUsernames(accountProvider: AccountProvider, username: String?) {
        switch accountProvider {
        case .Email:
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = nil
        case .Facebook:
            previousFacebookUsername.value = username
            previousGoogleUsername.value = nil
        case .Google:
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = username
        }
    }

    private func savePreviousEmailOrUsername(accountProvider: AccountProvider, username: String?) {
        keyValueStorage[.previousUserAccountProvider] = accountProvider.rawValue
        keyValueStorage[.previousUserEmailOrName] = username
    }
}
