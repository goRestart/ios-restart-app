import LGCoreKit
import Result
import LGComponents

protocol RememberPasswordViewModelDelegate: BaseViewModelDelegate {
    func viewModel(_ viewModel: RememberPasswordViewModel, updateSendButtonEnabledState enabled: Bool)
}


class RememberPasswordViewModel: BaseViewModel {
    let sessionManager: SessionManager
    let tracker: Tracker
    let loginSource: EventParameterLoginSourceValue

    weak var delegate: RememberPasswordViewModelDelegate?
    
    var router: RememberPasswordWireframe?
    
    // Input
    var email: String {
        didSet {
            email = email.trim
            delegate?.viewModel(self, updateSendButtonEnabledState: sendButtonShouldBeEnabled())
        }
    }
    
    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, tracker: Tracker, source: EventParameterLoginSourceValue, email: String?) {
        self.sessionManager = sessionManager
        self.tracker = tracker
        self.email = email ?? ""
        self.loginSource = source
        super.init()
    }
    
    convenience init(source: EventParameterLoginSourceValue, email: String?) {
        let sessionManager = Core.sessionManager
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, tracker: tracker, source: source, email: email)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        let event = TrackerEvent.passwordResetVisit()
        tracker.trackEvent(event)
    }

    
    // MARK: - Public methods

    func resetPassword() {
        if !email.isEmail() {
            delegate?.vmShowAutoFadingMessage(R.Strings.resetPasswordSendErrorInvalidEmail, completion: nil)
        } else {
            delegate?.vmShowLoading(nil)
            sessionManager.recoverPassword(email) { [weak self] recoverPwdResult in
                guard let strongSelf = self else { return }

                switch (recoverPwdResult) {
                case .success:
                    strongSelf.delegate?.vmHideLoading(R.Strings.resetPasswordSendOk(strongSelf.email),
                                                       afterMessageCompletion: {
                        self?.router?.closeRememberPassword()
                    })
                case .failure(let error):
                    var errorMessage: String?
                    var errorDescription: EventParameterLoginError?
                    switch (error) {
                    case .network:
                        errorMessage = R.Strings.commonErrorConnectionFailed
                        errorDescription = .network
                    case .badRequest(let cause):
                        switch cause {
                        case .nonAcceptableParams:
                            errorDescription = .blacklistedDomain
                        case .notSpecified, .other:
                            errorDescription = .internalError(description: "BadRequest")
                        }
                        errorMessage = R.Strings.resetPasswordSendErrorGeneric
                    case .notFound:
                        errorMessage = R.Strings.resetPasswordSendErrorUserNotFoundOrWrongPassword(
                            strongSelf.email)
                        errorDescription = .notFound
                    case .conflict, .tooManyRequests:
                        errorMessage = R.Strings.resetPasswordSendTooManyRequests
                        errorDescription = .tooManyRequests
                    case .scammer:
                        errorMessage = R.Strings.resetPasswordSendErrorGeneric
                        errorDescription = .scammer
                    case let .internalError(description):
                        errorMessage = R.Strings.resetPasswordSendErrorGeneric
                        errorDescription = .internalError(description: description)
                    case .userNotVerified:
                        errorMessage = R.Strings.resetPasswordSendErrorGeneric
                        errorDescription = .internalError(description: "UserNotVerified")
                    case .forbidden:
                        errorMessage = R.Strings.resetPasswordSendErrorGeneric
                        errorDescription = .forbidden
                    case .unauthorized:
                        errorMessage = R.Strings.resetPasswordSendErrorGeneric
                        errorDescription = .unauthorized
                    case .nonExistingEmail:
                        errorMessage = R.Strings.resetPasswordSendErrorGeneric
                        errorDescription = .nonExistingEmail
                    }
                    if let errorDescription = errorDescription {
                        let event = TrackerEvent.passwordResetError(errorDescription)
                        strongSelf.tracker.trackEvent(event)
                    }

                    if let errorMessage = errorMessage {
                        strongSelf.delegate?.vmHideLoading(errorMessage, afterMessageCompletion: nil)
                    }
                }
            }
        }
    }

    // MARK: - Private methods
    
    private func sendButtonShouldBeEnabled() -> Bool {
        return email.count > 0
    }
}
