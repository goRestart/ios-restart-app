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

enum VerifyButtonState {
    case hidden
    case enabled
    case disabled
    case loading
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

    let fbButtonState = Variable<VerifyButtonState>(.Hidden)
    let googleButtonState = Variable<VerifyButtonState>(.Hidden)
    let emailButtonState = Variable<VerifyButtonState>(.Hidden)
    let typedEmailState = Variable<VerifyButtonState>(.Hidden)
    private(set) var emailRequiresInput = false
    let typedEmail = Variable<String>("")

    private let googleHelper: GoogleLoginHelper
    private let fbLoginHelper: FBLoginHelper
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    private let source: VerifyAccountsSource
    private let types: [VerificationType]
    private var userEmail: String? {
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
        self.types = verificationTypes
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
            typedEmailState.value = .Disabled
            emailButtonState.value = .Hidden
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
                googleButtonState.value = .Enabled
            case .facebook:
                fbButtonState.value = .Enabled
            case let .email(email):
                emailRequiresInput = !(email ?? "").isEmail()
                emailButtonState.value = .Enabled
            }
        }
    }

    private func setupRx() {
        guard emailRequiresInput else { return }
        typedEmail.asObservable()
            .filter { [weak self] _ in
                guard let actionState = self?.typedEmailState.value, let buttonState = self?.emailButtonState.value else { return false }
                return actionState != .Loading && buttonState == .Hidden
            }
            .map{ ($0 ?? "").isEmail() ? VerifyButtonState.Enabled : VerifyButtonState.Disabled }
            .bindNext { [weak self] state in
                self?.typedEmailState.value = state
            }.addDisposableTo(disposeBag)
    }
}


// MARK: - Private actions

private extension VerifyAccountsViewModel {
    func connectWithFacebook() {
        fbButtonState.value = .Loading
        fbLoginHelper.connectWithFacebook { [weak self] result in
            self?.fbButtonState.value = .Enabled
            switch result {
            case let .success(token):
                self?.myUserRepository.linkAccountFacebook(token) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.Facebook)
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
        googleButtonState.value = .Loading
        googleHelper.googleSignIn { [weak self] result in
            self?.googleButtonState.value = .Enabled
            switch result {
            case let .success(serverAuthToken):
                self?.myUserRepository.linkAccountGoogle(serverAuthToken) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.Google)
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
                case .TooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests, completion: { self?.verificationFailed() })
                case .Network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody, completion: { self?.verificationFailed() })
                case .Forbidden, .Internal, .NotFound, .Unauthorized, .UserNotVerified, .ServerError:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: { self?.verificationFailed() })
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess) {
                    self?.verificationSuccess(.Email(email))
                }
            }
        }
    }

    func setEmailLoading(_ loading: Bool) {
        if emailButtonState.value != .Hidden {
            emailButtonState.value = loading ? .Loading : .Enabled
        }
        if typedEmailState.value != .Hidden {
            typedEmailState.value = loading ? .Loading : .Enabled
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

private extension VerifyAccountsViewModel {
    func trackStart() {
        let event = TrackerEvent.verifyAccountStart(source.typePage)
        tracker.trackEvent(event)
    }

    func trackComplete(_ verificationType: VerificationType) {
        let event = TrackerEvent.verifyAccountComplete(source.typePage, network: verificationType.accountNetwork)
        tracker.trackEvent(event)
    }
}

private extension VerifyAccountsSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .chat:
            return .Chat
        case .profile:
            return .Profile
        }
    }

    var loginSource: EventParameterLoginSourceValue {
        switch self {
        case .chat:
            return .Chats
        case .profile:
            return .Profile
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

private extension VerificationType {
    var accountNetwork: EventParameterAccountNetwork {
        switch self {
        case .facebook:
            return .Facebook
        case .google:
            return .Google
        case .email:
            return .Email
        }
    }
}
