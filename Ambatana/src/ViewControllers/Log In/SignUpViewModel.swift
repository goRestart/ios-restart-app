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

// This should become a navigator
protocol SignUpViewModelDelegate: BaseViewModelDelegate {
    func vmOpenSignup(viewModel: SignUpLogInViewModel)
    func vmFinish(completedLogin completed: Bool)
    func vmFinishAndShowScammerAlert(contactUrl: NSURL, network: EventParameterAccountNetwork, tracker: Tracker)
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
    private let installationRepository: InstallationRepository
    private let keyValueStorage: KeyValueStorageable
    private let featureFlags: FeatureFlaggeable
    private let tracker: Tracker
    let appearance: LoginAppearance
    private let loginSource: EventParameterLoginSourceValue

    private let googleLoginHelper: ExternalAuthHelper
    private let fbLoginHelper: ExternalAuthHelper

    let previousFacebookUsername: Variable<String?>
    let previousGoogleUsername: Variable<String?>

    weak var delegate: SignUpViewModelDelegate?


    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, installationRepository: InstallationRepository,
         keyValueStorage: KeyValueStorageable, featureFlags: FeatureFlaggeable, tracker: Tracker, appearance: LoginAppearance,
         source: EventParameterLoginSourceValue, googleLoginHelper: ExternalAuthHelper, fbLoginHelper: ExternalAuthHelper) {
        self.sessionManager = sessionManager
        self.installationRepository = installationRepository
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.appearance = appearance
        self.loginSource = source
        self.googleLoginHelper = googleLoginHelper
        self.fbLoginHelper = fbLoginHelper
        self.previousFacebookUsername = Variable<String?>(nil)
        self.previousGoogleUsername = Variable<String?>(nil)
        super.init()

        let rememberedAccount = updatePreviousEmailAndUsernamesFromKeyValueStorage()

        // Tracking
        tracker.trackEvent(TrackerEvent.loginVisit(loginSource, rememberedAccount: rememberedAccount))
    }
    
    convenience init(appearance: LoginAppearance, source: EventParameterLoginSourceValue) {
        let sessionManager = Core.sessionManager
        let installationRepository = Core.installationRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let googleLoginHelper = GoogleLoginHelper()
        let fbLoginHelper = FBLoginHelper()
        self.init(sessionManager: sessionManager, installationRepository: installationRepository,
                  keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: appearance,
                  source: source, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        let trackerEvent = TrackerEvent.loginAbandon(loginSource)
        tracker.trackEvent(trackerEvent)

        delegate?.vmFinish(completedLogin: false)
    }

    func connectFBButtonPressed() {
        logInWithFacebook()
    }

    func connectGoogleButtonPressed() {
        logInWithGoogle()
    }

    func signUpButtonPressed() {
        let vm = SignUpLogInViewModel(source: loginSource, action: .Signup)
        delegate?.vmOpenSignup(vm)
    }

    func logInButtonPressed() {
        let vm = SignUpLogInViewModel(source: loginSource, action: .Login)
        delegate?.vmOpenSignup(vm)
    }


    // MARK: - Private methods

    private func logInWithFacebook() {
        fbLoginHelper.login({ [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.vmShowLoading(nil)
            }, loginCompletion: { [weak self] result in
                let error = self?.processAuthResult(result, accountProvider: .Facebook)
                switch result {
                case .Success:
                    self?.trackLoginFBOK()
                default:
                    break
                }
                if let error = error {
                    self?.trackLoginFBFailedWithError(error)
                }
            })
    }

    private func logInWithGoogle() {
        googleLoginHelper.login({ [weak self] in
            // Google OAuth completed. Token obtained
            guard let strongSelf = self else { return }
            strongSelf.delegate?.vmShowLoading(nil)
        }) { [weak self] result in
            let error = self?.processAuthResult(result, accountProvider: .Google)
            switch result {
            case .Success:
                self?.trackLoginGoogleOK()
            default:
                break
            }
            if let error = error {
                self?.trackLoginGoogleFailedWithError(error)
            }
        }
    }

    private func processAuthResult(result: ExternalServiceAuthResult,
                                   accountProvider: AccountProvider) -> EventParameterLoginError? {
        var loginError: EventParameterLoginError? = nil
        switch result {
        case let .Success(myUser):
            savePreviousEmailOrUsername(accountProvider, username: myUser.name)
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.delegate?.vmFinish(completedLogin: true)
            }
        case .Cancelled:
            delegate?.vmHideLoading(nil, afterMessageCompletion: nil)
        case .Network:
            delegate?.vmHideLoading(LGLocalizedString.mainSignUpFbConnectErrorGeneric, afterMessageCompletion: nil)
            loginError = .Network
        case .Scammer:
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(accountProvider.accountNetwork)
            }
            loginError = .Forbidden
        case .NotFound:
            delegate?.vmHideLoading(LGLocalizedString.mainSignUpFbConnectErrorGeneric, afterMessageCompletion: nil)
            loginError = .UserNotFoundOrWrongPassword
        case .BadRequest:
            delegate?.vmHideLoading(LGLocalizedString.mainSignUpFbConnectErrorGeneric, afterMessageCompletion: nil)
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
            delegate?.vmHideLoading(message, afterMessageCompletion: nil)
            loginError = .EmailTaken
        case let .Internal(description):
            delegate?.vmHideLoading(LGLocalizedString.mainSignUpFbConnectErrorGeneric, afterMessageCompletion: nil)
            loginError = .Internal(description: description)
        }
        return loginError
    }

    private func showScammerAlert(network: EventParameterAccountNetwork) {
        guard let url = LetgoURLHelper.buildContactUsURL(userEmail: nil,
            installation: installationRepository.installation, moderation: true) else {
                delegate?.vmFinish(completedLogin: false)
                return
            }

        delegate?.vmFinishAndShowScammerAlert(url, network: network, tracker: tracker)
    }

    private func trackLoginFBOK() {
        let rememberedAccount = previousFacebookUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginFB(loginSource, rememberedAccount: rememberedAccount))
    }

    private func trackLoginFBFailedWithError(error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginFBError(error))
    }

    private func trackLoginGoogleOK() {
        let rememberedAccount = previousGoogleUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginGoogle(loginSource, rememberedAccount: rememberedAccount))
    }

    private func trackLoginGoogleFailedWithError(error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginGoogleError(error))
    }
}


// MARK: > Previous user name

private extension SignUpViewModel {
    private func updatePreviousEmailAndUsernamesFromKeyValueStorage() -> Bool {
        guard let accountProviderString = keyValueStorage[.previousUserAccountProvider],
            accountProvider = AccountProvider(rawValue: accountProviderString) else { return false }

        let username = keyValueStorage[.previousUserEmailOrName]
        updatePreviousEmailAndUsernames(accountProvider, username: username)
        return true
    }

    private func updatePreviousEmailAndUsernames(accountProvider: AccountProvider, username: String?) {
        guard featureFlags.saveMailLogout else { return }

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
        guard featureFlags.saveMailLogout else { return }

        keyValueStorage[.previousUserAccountProvider] = accountProvider.rawValue
        keyValueStorage[.previousUserEmailOrName] = username
    }
}
