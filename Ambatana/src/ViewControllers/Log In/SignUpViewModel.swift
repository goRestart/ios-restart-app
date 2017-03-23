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
    case dark, light
}

protocol SignUpViewModelDelegate: BaseViewModelDelegate {}

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
        paragraphStyle.alignment = .center
        attributtedLegalText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
        return attributtedLegalText
    }

    private var termsAndConditionsURL: URL? {
        return LetgoURLHelper.buildTermsAndConditionsURL()
    }
    private var privacyURL: URL? {
        return LetgoURLHelper.buildPrivacyURL()
    }

    fileprivate let sessionManager: SessionManager
    fileprivate let installationRepository: InstallationRepository
    fileprivate let keyValueStorage: KeyValueStorageable
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let tracker: Tracker
    let appearance: LoginAppearance
    fileprivate let loginSource: EventParameterLoginSourceValue
    var collapsedEmailTrackingParam: EventParameterBoolean? = nil

    private let googleLoginHelper: ExternalAuthHelper
    private let fbLoginHelper: ExternalAuthHelper

    let previousFacebookUsername: Variable<String?>
    let previousGoogleUsername: Variable<String?>

    weak var delegate: SignUpViewModelDelegate?
    weak var navigator: MainSignUpNavigator?


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

        navigator?.cancelMainSignUp()
    }

    func connectFBButtonPressed() {
        logInWithFacebook()
    }

    func connectGoogleButtonPressed() {
        logInWithGoogle()
    }

    func signUpButtonPressed() {
        navigator?.openSignUpEmailFromMainSignUp(collapsedEmailParam: collapsedEmailTrackingParam)
    }

    func logInButtonPressed() {
        navigator?.openLogInEmailFromMainSignUp(collapsedEmailParam: collapsedEmailTrackingParam)
    }

    func helpButtonPressed() {
        navigator?.openHelpFromMainSignUp()
    }

    func urlPressed(url: URL) {
        navigator?.open(url: url)
    }


    // MARK: - Private methods

    private func logInWithFacebook() {
        fbLoginHelper.login({ [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.vmShowLoading(nil)
            }, loginCompletion: { [weak self] result in
                self?.processAuthResult(result, accountProvider: .facebook)
                if result.isSuccess {
                    self?.trackLoginFBOK()
                } else if let trackingError = result.trackingError {
                    self?.trackLoginFBFailedWithError(trackingError)
                }
            })
    }

    private func logInWithGoogle() {
        googleLoginHelper.login({ [weak self] in
            // Google OAuth completed. Token obtained
            guard let strongSelf = self else { return }
            strongSelf.delegate?.vmShowLoading(nil)
        }) { [weak self] result in
            self?.processAuthResult(result, accountProvider: .google)
            if result.isSuccess {
                self?.trackLoginGoogleOK()
            } else if let trackingError = result.trackingError {
                self?.trackLoginGoogleFailedWithError(trackingError)
            }
        }
    }

    private func processAuthResult(_ result: ExternalServiceAuthResult, accountProvider: AccountProvider) {
        if let myUser = result.myUser {
            savePreviousEmailOrUsername(accountProvider, username: myUser.name)
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.navigator?.closeMainSignUpSuccessful(with: myUser)
            }
        } else if result.isScammer {
            delegate?.vmHideLoading(nil) { [weak self] in
                self?.showScammerAlert(accountProvider.accountNetwork)
            }
        } else {
            delegate?.vmHideLoading(result.errorMessage, afterMessageCompletion: nil)
        }
    }

    private func showScammerAlert(_ network: EventParameterAccountNetwork) {
        guard let contactURL = LetgoURLHelper.buildContactUsURL(userEmail: nil,
                                                                installation: installationRepository.installation,
                                                                moderation: true) else {
                navigator?.cancelMainSignUp()
                return
            }

        navigator?.closeMainSignUpAndOpenScammerAlert(contactURL: contactURL, network: network)
    }

    private func trackLoginFBOK() {
        let rememberedAccount = previousFacebookUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginFB(loginSource, rememberedAccount: rememberedAccount,
                                                collapsedEmail: collapsedEmailTrackingParam))
    }

    private func trackLoginFBFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginFBError(error))
    }

    private func trackLoginGoogleOK() {
        let rememberedAccount = previousGoogleUsername.value != nil
        tracker.trackEvent(TrackerEvent.loginGoogle(loginSource, rememberedAccount: rememberedAccount,
                                                    collapsedEmail: collapsedEmailTrackingParam))
    }

    private func trackLoginGoogleFailedWithError(_ error: EventParameterLoginError) {
        tracker.trackEvent(TrackerEvent.loginGoogleError(error))
    }
}


// MARK: > Previous user name

fileprivate extension SignUpViewModel {
    func updatePreviousEmailAndUsernamesFromKeyValueStorage() -> Bool {
        guard let accountProviderString = keyValueStorage[.previousUserAccountProvider],
            let accountProvider = AccountProvider(rawValue: accountProviderString) else { return false }

        let username = keyValueStorage[.previousUserEmailOrName]
        updatePreviousEmailAndUsernames(accountProvider, username: username)
        return true
    }

    func updatePreviousEmailAndUsernames(_ accountProvider: AccountProvider, username: String?) {
        switch accountProvider {
        case .email:
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = nil
        case .facebook:
            previousFacebookUsername.value = username
            previousGoogleUsername.value = nil
        case .google:
            previousFacebookUsername.value = nil
            previousGoogleUsername.value = username
        }
    }

    func savePreviousEmailOrUsername(_ accountProvider: AccountProvider, username: String?) {
        keyValueStorage[.previousUserAccountProvider] = accountProvider.rawValue
        keyValueStorage[.previousUserEmailOrName] = username
    }
}
