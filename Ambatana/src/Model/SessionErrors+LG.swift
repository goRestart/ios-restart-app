import LGCoreKit
import LGComponents

extension LoginError {
    var trackingError: EventParameterLoginError {
        switch (self) {
        case .network:
            return .network
        case .badRequest(let cause):
            switch cause {
            case .nonAcceptableParams:
                return .blacklistedDomain
            case .notSpecified, .other:
                return .badRequest
            }
        case .scammer:
            return .forbidden
        case .notFound:
            return .notFound
        case .conflict:
            return .emailTaken
        case .forbidden:
            return .forbidden
        case let .internalError(description):
            return .internalError(description: description)
        case .deviceNotAllowed:
            return .deviceNotAllowed
        case .unauthorized:
            return .unauthorized
        case .tooManyRequests:
            return .tooManyRequests
        case .userNotVerified:
            return .internalError(description: "UserNotVerified")
        }
    }

    var errorMessage: String? {
        switch self {
        case .network:
            return R.Strings.commonErrorConnectionFailed
        case .unauthorized:
            return R.Strings.logInErrorSendErrorUserNotFoundOrWrongPassword
        case .scammer, .deviceNotAllowed:
            return nil
        case .notFound, .internalError, .forbidden, .conflict, .tooManyRequests, .badRequest,
             .userNotVerified:
            return R.Strings.logInErrorSendErrorGeneric
        }

    }
}

extension SignupError {
    var trackingError: EventParameterLoginError {
        switch (self) {
        case .network:
            return .network
        case .badRequest(let cause):
            switch cause {
            case .nonAcceptableParams:
                return .blacklistedDomain
            case .notSpecified, .other:
                return .badRequest
            }
        case .scammer:
            return .forbidden
        case .notFound:
            return .notFound
        case .conflict:
            return .emailTaken
        case .forbidden:
            return .forbidden
        case let .internalError(description):
            return .internalError(description: description)
        case .nonExistingEmail:
            return .nonExistingEmail
        case .unauthorized:
            return .unauthorized
        case .tooManyRequests:
            return .tooManyRequests
        case .userNotVerified:
            return .internalError(description: "UserNotVerified")
        }
    }

    var isUserExists: Bool {
        switch self {
        case .conflict(let cause):
            switch cause {
            case .userExists:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }

    func errorMessage(userEmail: String?) -> String? {
        switch self {
        case .network:
            return R.Strings.commonErrorConnectionFailed
        case .badRequest(let cause):
            switch cause {
            case .notSpecified, .other:
                return R.Strings.signUpSendErrorGeneric
            case .nonAcceptableParams:
                return R.Strings.signUpSendErrorInvalidDomain
            }
        case .conflict(let cause):
            switch cause {
            case .userExists, .notSpecified, .other, .searchAlertLimitReached, .searchAlertAlreadyExists:
                if let email = userEmail {
                    return R.Strings.signUpSendErrorEmailTaken(email)
                } else {
                    return R.Strings.signUpSendErrorGeneric
                }
            case .emailRejected:
                return R.Strings.mainSignUpErrorUserRejected
            case .requestAlreadyProcessed:
                return R.Strings.mainSignUpErrorRequestAlreadySent
            }
        case .nonExistingEmail:
            return R.Strings.signUpSendErrorInvalidEmail
        case .scammer, .userNotVerified:
            return nil
        case .notFound, .internalError, .forbidden, .unauthorized, .tooManyRequests:
            return R.Strings.signUpSendErrorGeneric
        }
    }
}

extension RecoverPasswordError {
    var trackingError: EventParameterLoginError {
        switch self {
        case .network:
            return .network
        case .badRequest(let cause):
            switch cause {
            case .nonAcceptableParams:
                return .blacklistedDomain
            case .notSpecified, .other:
                return .badRequest
            }
        case .scammer:
            return .forbidden
        case .notFound:
            return .notFound
        case .conflict:
            return .emailTaken
        case .forbidden:
            return .forbidden
        case let .internalError(description):
            return .internalError(description: description)
        case .nonExistingEmail:
            return .nonExistingEmail
        case .unauthorized:
            return .unauthorized
        case .tooManyRequests:
            return .tooManyRequests
        case .userNotVerified:
            return .internalError(description: "UserNotVerified")
        }
    }
}
