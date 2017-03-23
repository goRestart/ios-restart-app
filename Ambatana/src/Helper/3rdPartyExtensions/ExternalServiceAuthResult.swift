//
//  ExternalServiceAuthenticationHelper.swift
//  LetGo
//
//  Created by Isaac Roldan on 16/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

enum ExternalServiceAuthResult {
    case success(myUser: MyUser)
    case cancelled
    case network
    case scammer
    case deviceNotAllowed
    case notFound
    case conflict(cause: ConflictCause)
    case badRequest
    case internalError(description: String)
    case loginError(error: LoginError)
    
    init(loginError: LoginError) {
        switch loginError {
        case .conflict(let cause):
            self = .conflict(cause: cause)
        case .badRequest:
            self = .badRequest
        case let .internalError(description):
            self = .internalError(description: description)
        case .notFound:
            self = .notFound
        case .scammer:
            self = .scammer
        case .deviceNotAllowed:
            self = .deviceNotAllowed
        case .network:
            self = .network
        default:
            self = .loginError(error: loginError)
        }
    }

    var myUser: MyUser? {
        switch self {
        case let .success(myUser):
            return myUser
        default:
            return nil
        }
    }

    var isSuccess: Bool {
        return myUser != nil
    }

    var isCancelled: Bool {
        switch self {
        case .cancelled:
            return true
        default:
            return false
        }
    }

    var isScammer: Bool {
        switch self {
        case .scammer:
            return true
        default:
            return false
        }
    }

    var isDeviceNotAllowed: Bool {
        switch self {
        case .deviceNotAllowed:
            return true
        default:
            return false
        }
    }

    var trackingError: EventParameterLoginError? {
        switch self {
        case .success, .cancelled:
            return nil
        case .network:
            return .network
        case .scammer:
            return .forbidden
        case .deviceNotAllowed:
            return .deviceNotAllowed
        case .notFound:
            return .userNotFoundOrWrongPassword
        case .badRequest:
            return .badRequest
        case .conflict:
            return .emailTaken
        case let .loginError(error):
            return error.trackingError
        case let .internalError(description):
            return .internalError(description: description)
        }
    }

    var errorMessage: String? {
        switch self {
        case .success, .cancelled, .scammer, .deviceNotAllowed:
            return nil
        case .conflict(let cause):
            switch cause {
            case .userExists, .notSpecified, .other:
                return LGLocalizedString.mainSignUpFbConnectErrorEmailTaken
            case .emailRejected:
                return LGLocalizedString.mainSignUpErrorUserRejected
            case .requestAlreadyProcessed:
                return LGLocalizedString.mainSignUpErrorRequestAlreadySent
            }
        case .network, .notFound, .badRequest, .internalError, .loginError:
            return LGLocalizedString.mainSignUpFbConnectErrorGeneric
        }
    }
}

enum ExternalAuthTokenRetrievalResult {
    case success(serverAuthCode: String)
    case cancelled
    case error(error: Error?)
}

typealias ExternalAuthTokenRetrievalCompletion = (ExternalAuthTokenRetrievalResult) -> ()
