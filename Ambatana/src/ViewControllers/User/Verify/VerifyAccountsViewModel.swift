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
    case Hidden
    case Enabled
    case Disabled
    case Loading
}

enum VerifyAccountsSource {
    case Chat(description: String)
    case Profile(description: String)
}


class VerifyAccountsViewModel: BaseViewModel {
    weak var delegate: VerifyAccountsViewModelDelegate?

    var descriptionText: String {
        return source.description
    }

    let fbButtonState = Variable<VerifyButtonState>(.Hidden)
    let googleButtonState = Variable<VerifyButtonState>(.Hidden)
    let emailButtonState = Variable<VerifyButtonState>(.Hidden)
    let typedEmailState = Variable<VerifyButtonState>(.Hidden)
    private(set) var emailRequiresInput = false
    let typedEmail = Variable<String>("")

    private let googleHelper: GoogleLoginHelper
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    private let source: VerifyAccountsSource
    private let types: [VerificationType]
    private var userEmail: String? {
        for type in types {
            switch type {
            case .Google, .Facebook:
                continue
            case let .Email(email):
                guard let email = email where email.isEmail() else { return nil }
                return email
            }
        }
        return nil
    }

    private let disposeBag = DisposeBag()

    convenience init(verificationTypes: [VerificationType], source: VerifyAccountsSource) {
        let myUserRepository = Core.myUserRepository
        let googleHelper = GoogleLoginHelper(loginSource: source.loginSource)
        let tracker = TrackerProxy.sharedInstance
        self.init(verificationTypes: verificationTypes, source: source, myUserRepository: myUserRepository,
                  googleHelper: googleHelper, tracker: tracker)
    }

    init(verificationTypes: [VerificationType], source: VerifyAccountsSource, myUserRepository: MyUserRepository,
         googleHelper: GoogleLoginHelper, tracker: Tracker) {
        self.types = verificationTypes
        self.source = source
        self.myUserRepository = myUserRepository
        self.googleHelper = googleHelper
        self.tracker = tracker
        super.init()

        setupState()
        setupRx()
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            trackStart()
        }
    }


    // MARK: - Public

    func closeButtonPressed() {
        delegate?.vmResignResponders()
        delegate?.vmDismiss(nil)
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
        if let presentEmail = userEmail where presentEmail.isEmail() {
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
            case .Google:
                googleButtonState.value = .Enabled
            case .Facebook:
                fbButtonState.value = .Enabled
            case let .Email(email):
                emailRequiresInput = !(email ?? "").isEmail()
                emailButtonState.value = .Enabled
            }
        }
    }

    private func setupRx() {
        guard emailRequiresInput else { return }
        typedEmail.asObservable()
            .filter { [weak self] _ in
                guard let actionState = self?.typedEmailState.value, buttonState = self?.emailButtonState.value else { return false }
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
        FBLoginHelper.connectWithFacebook { [weak self] result in
            self?.fbButtonState.value = .Enabled
            switch result {
            case let .Success(token):
                self?.myUserRepository.linkAccountFacebook(token) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.Facebook)
                        self?.delegate?.vmDismiss(nil)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
                    }
                }
            case .Cancelled:
                break
            case .Error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
            }
        }
    }

    func connectWithGoogle() {
        googleButtonState.value = .Loading
        googleHelper.googleSignIn { [weak self] result in
            self?.googleButtonState.value = .Enabled
            switch result {
            case let .Success(serverAuthToken):
                self?.myUserRepository.linkAccountGoogle(serverAuthToken) { result in
                    if let _ = result.value {
                        self?.verificationSuccess(.Google)
                        self?.delegate?.vmDismiss(nil)
                    } else {
                        self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
                    }
                }
            case .Cancelled:
                break
            case .Error:
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.mainSignUpFbConnectErrorGeneric, completion: nil)
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
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests, completion: nil)
                case .Network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody, completion: nil)
                case .Forbidden, .Internal, .NotFound, .Unauthorized, .UserNotVerified, .ServerError:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: nil)
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess) {
                    self?.delegate?.vmDismiss(nil)
                }
            }
        }
    }

    private func setEmailLoading(loading: Bool) {
        if emailButtonState.value != .Hidden {
            emailButtonState.value = loading ? .Loading : .Enabled
        }
        if typedEmailState.value != .Hidden {
            typedEmailState.value = loading ? .Loading : .Enabled
        }
    }

    func verificationSuccess(verificationType: VerificationType) {
        trackComplete(verificationType)
        delegate?.vmDismiss(nil)
    }
}


// MARK: - Trackings

private extension VerifyAccountsViewModel {
    func trackStart() {
        let event = TrackerEvent.verifyAccountStart(source.typePage)
        tracker.trackEvent(event)
    }

    func trackComplete(verificationType: VerificationType) {
        let event = TrackerEvent.verifyAccountComplete(source.typePage, network: verificationType.accountNetwork)
        tracker.trackEvent(event)
    }
}

private extension VerifyAccountsSource {
    var typePage: EventParameterTypePage {
        switch self {
        case .Chat:
            return .Chat
        case .Profile:
            return .Profile
        }
    }

    var loginSource: EventParameterLoginSourceValue {
        switch self {
        case .Chat:
            return .Chats
        case .Profile:
            return .Profile
        }
    }

    var description: String {
        switch self {
        case let .Chat(description):
            return description
        case let .Profile(description):
            return description
        }
    }
}

private extension VerificationType {
    var accountNetwork: EventParameterAccountNetwork {
        switch self {
        case .Facebook:
            return .Facebook
        case .Google:
            return .Google
        case .Email:
            return .Email
        }
    }
}
