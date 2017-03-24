//
//  SessionErrors+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 23/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

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
            return LGLocalizedString.commonErrorConnectionFailed
        case .unauthorized:
            return LGLocalizedString.logInErrorSendErrorUserNotFoundOrWrongPassword
        case .scammer, .deviceNotAllowed:
            return nil
        case .notFound, .internalError, .forbidden, .conflict, .tooManyRequests, .badRequest,
             .userNotVerified:
            return LGLocalizedString.logInErrorSendErrorGeneric
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
            return LGLocalizedString.commonErrorConnectionFailed
        case .badRequest(let cause):
            switch cause {
            case .notSpecified, .other:
                return LGLocalizedString.signUpSendErrorGeneric
            case .nonAcceptableParams:
                return LGLocalizedString.signUpSendErrorInvalidDomain
            }
        case .conflict(let cause):
            switch cause {
            case .userExists, .notSpecified, .other:
                if let email = userEmail {
                    return LGLocalizedString.signUpSendErrorEmailTaken(email)
                } else {
                    return LGLocalizedString.signUpSendErrorGeneric
                }
            case .emailRejected:
                return LGLocalizedString.mainSignUpErrorUserRejected
            case .requestAlreadyProcessed:
                return LGLocalizedString.mainSignUpErrorRequestAlreadySent
            }
        case .nonExistingEmail:
            return LGLocalizedString.signUpSendErrorInvalidEmail
        case .scammer, .userNotVerified:
            return nil
        case .notFound, .internalError, .forbidden, .unauthorized, .tooManyRequests:
            return LGLocalizedString.signUpSendErrorGeneric
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
