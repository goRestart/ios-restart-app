//
//  VerifyAccountsViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 30/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift


protocol VerifyAccountsViewModelDelegate: BaseViewModelDelegate {
    func vmResignResponders()
}

enum VerifyAccountsSource {
    case chat(title: String, description: String)
    case profile(title: String, description: String)
}

enum VerificationType {
    case facebook, google, email(String?)
}


class VerifyAccountsViewModel: BaseViewModel {
    weak var delegate: VerifyAccountsViewModelDelegate?

    var titleText: String {
        return source.title
    }
    var descriptionText: String {
        return source.description
    }

    var completionBlock: (() -> Void)?

    let fbButtonState = Variable<ButtonState>(.hidden)
    let googleButtonState = Variable<ButtonState>(.hidden)
    let emailButtonState = Variable<ButtonState>(.hidden)
    let typedEmailState = Variable<ButtonState>(.hidden)
    private(set) var emailRequiresInput = false
    let typedEmail = Variable<String>("")

    fileprivate let googleHelper: GoogleLoginHelper
    fileprivate let fbLoginHelper: FBLoginHelper
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let tracker: Tracker
    fileprivate let source: VerifyAccountsSource
    private let types: [VerificationType]
    fileprivate var userEmail: String? {
        for type in types {
            switch type {
            case .google, .facebook:
                continue
            case let .email(email):
                guard let email = email, email.isEmail() else { return nil }
                return email
            }
        }
        return nil
    }

    private let disposeBag = DisposeBag()

    convenience init(verificationTypes: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {
        let myUserRepository = Core.myUserRepository
        let googleHelper = GoogleLoginHelper()
        let fbLoginHelper = FBLoginHelper()
        let tracker = TrackerProxy.sharedInstance
        self.init(verificationTypes: verificationTypes, source: source, myUserRepository: myUserRepository,
                  googleHelper: googleHelper, fbLoginHelper: fbLoginHelper, tracker: tracker,
                  completionBlock: completionBlock)
    }

    init(verificationTypes: [VerificationType], source: VerifyAccountsSource, myUserRepository: MyUserRepository,
         googleHelper: GoogleLoginHelper, fbLoginHelper: FBLoginHelper,
         tracker: Tracker, completionBlock: (() -> Void)?) {
        self.types = [.facebook, .google, .email("isaac.roldan+123@gmail.com")]// verificationTypes
        self.source = source
        self.myUserRepository = myUserRepository
        self.googleHelper = googleHelper
        self.fbLoginHelper = fbLoginHelper
        self.tracker = tracker
        self.completionBlock = completionBlock
        super.init()

        setupState()
        setupRx()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            trackStart()
        }
    }


    // MARK: - Public

    func closeButtonPressed() {
        delegate?.vmResignResponders()
        delegate?.vmDismiss(completionBlock)
    }

    func googleButtonPressed() {
        delegate?.vmResignResponders()
        connectWithGoogle()
    }

    func fbButtonPressed() {
        delegate?.vmResignResponders()
        connectWithFacebook()
    }

    func emailButtonPressed() {
        delegate?.vmResignResponders()
        if let presentEmail = userEmail, presentEmail.isEmail() {
            emailVerification()
        } else {
            typedEmailState.value = .disabled
            emailButtonState.value = .hidden
        }
    }

    func typedEmailButtonPressed() {
        delegate?.vmResignResponders()
        emailVerification()
    }


    // MARK: - Setup

    private func setupState() {
        types.forEach {
            switch $0 {
            case .google:
                googleButtonState.value = .enabled
            case .facebook:
                fbButtonState.value = .enabled
            case let .email(email):
                emailRequiresInput = !(email ?? "").isEmail()
                emailButtonState.value = .enabled
            }
        }
    }

    private func setupRx() {
        guard emailRequiresInput else { return }
        typedEmail.asObservable()
            .filter { [weak self] _ in
                guard let actionState = self?.typedEmailState.value, let buttonState = self?.emailButtonState.value else { return false }
                return actionState != .loading && buttonState == .hidden
            }
            .map{ $0.isEmail() ? ButtonState.enabled : ButtonState.disabled }
            .bind { [weak self] state in
                self?.typedEmailState.value = state
            }.disposed(by: disposeBag)
    }
}


// MARK: - Private actions

fileprivate extension VerifyAccountsViewModel {
    func connectWithFacebook() {
        fbButtonState.value = .loading
        fbLoginHelper.connectWithFacebook { [weak self] result in
            self?.fbButtonState.value = .enabled
            switch result {
            case let .success(token):
                self?.myUserRepository.linkAccountFacebook(token) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.facebook)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: { self?.verificationFailed() })
                    }
                }
            case .cancelled:
                break
            case .error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: { self?.verificationFailed() })
            }
        }
    }

    func connectWithGoogle() {
        googleButtonState.value = .loading
        googleHelper.googleSignIn { [weak self] result in
            self?.googleButtonState.value = .enabled
            switch result {
            case let .success(serverAuthToken):
                self?.myUserRepository.linkAccountGoogle(serverAuthToken) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.google)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: { self?.verificationFailed() })
                    }
                }
            case .cancelled:
                break
            case .error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: { self?.verificationFailed() })
            }
        }
    }

    func emailVerification() {
        let email = userEmail ?? typedEmail.value
        guard email.isEmail() else { return }
        setEmailLoading(true)
        myUserRepository.linkAccount(email) { [weak self] result in
            self?.setEmailLoading(false)
            if let error = result.error {
                switch error {
                case .tooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests, completion: { self?.verificationFailed() })
                case .network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody, completion: { self?.verificationFailed() })
                case .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified, .serverError, .wsChatError:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: { self?.verificationFailed() })
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess) {
                    self?.verificationSuccess(.email(email))
                }
            }
        }
    }

    func setEmailLoading(_ loading: Bool) {
        if emailButtonState.value != .hidden {
            emailButtonState.value = loading ? .loading : .enabled
        }
        if typedEmailState.value != .hidden {
            typedEmailState.value = loading ? .loading : .enabled
        }
    }

    func verificationSuccess(_ verificationType: VerificationType) {
        trackComplete(verificationType)
        delegate?.vmDismiss(completionBlock)
    }

    func verificationFailed() {
        delegate?.vmDismiss(completionBlock)
    }
}


// MARK: - Trackings

fileprivate extension VerifyAccountsViewModel {
    func trackStart() {
        let event = TrackerEvent.verifyAccountStart(source.typePage)
        tracker.trackEvent(event)
    }

    func trackComplete(_ verificationType: VerificationType) {
        let event = TrackerEvent.verifyAccountComplete(source.typePage, network: verificationType.accountNetwork)
        tracker.trackEvent(event)
    }
}

fileprivate extension VerifyAccountsSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .chat:
            return .chat
        case .profile:
            return .profile
        }
    }

    var loginSource: EventParameterLoginSourceValue {
        switch self {
        case .chat:
            return .chats
        case .profile:
            return .profile
        }
    }

    var title: String {
        switch self {
        case let .chat(title, _):
            return title
        case let .profile(title, _):
            return title
        }
    }

    var description: String {
        switch self {
        case let .chat(_, description):
            return description
        case let .profile(_, description):
            return description
        }
    }
}

fileprivate extension VerificationType {
    var accountNetwork: EventParameterAccountNetwork {
        switch self {
        case .facebook:
            return .facebook
        case .google:
            return .google
        case .email:
            return .email
        }
    }
}
