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
    case notFound
    case conflict(cause: ConflictCause)
    case badRequest
    case internalError(description: String)
    
    init(sessionError: SessionManagerError) {
        switch sessionError {
        case .conflict(let cause):
            self = .conflict(cause: cause)
        case .badRequest:
            self = .badRequest
        case let .internalError(description):
            self = .internalError(description: description)
        case .nonExistingEmail:
            self = .internalError(description: "NonExistingEmail")
        case .unauthorized:
            self = .internalError(description: "Unauthorized")
        case .forbidden:
            self = .internalError(description: "Forbidden")
        case .tooManyRequests:
            self = .internalError(description: "TooManyRequests")
        case .userNotVerified:
            self = .internalError(description: "UserNotVerified")
        case .notFound:
            self = .notFound
        case .scammer:
            self = .scammer
        case .network:
            self = .network
        }
    }
}

enum ExternalAuthTokenRetrievalResult {
    case success(serverAuthCode: String)
    case cancelled
    case error(error: Error?)
}

typealias ExternalAuthTokenRetrievalCompletion = (ExternalAuthTokenRetrievalResult) -> ()
