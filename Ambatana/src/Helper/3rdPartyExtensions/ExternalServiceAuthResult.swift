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
        case .Conflict(let cause):
            self = .Conflict(cause: cause)
        case .BadRequest:
            self = .BadRequest
        case let .Internal(description):
            self = .Internal(description: description)
        case .NonExistingEmail:
            self = .Internal(description: "NonExistingEmail")
        case .Unauthorized:
            self = .Internal(description: "Unauthorized")
        case .Forbidden:
            self = .Internal(description: "Forbidden")
        case .TooManyRequests:
            self = .Internal(description: "TooManyRequests")
        case .UserNotVerified:
            self = .Internal(description: "UserNotVerified")
        case .NotFound:
            self = .NotFound
        case .Scammer:
            self = .Scammer
        case .network:
            self = .network
        }
    }
}

enum ExternalAuthTokenRetrievalResult {
    case success(serverAuthCode: String)
    case cancelled
    case error(error: NSError?)
}

typealias ExternalAuthTokenRetrievalCompletion = (ExternalAuthTokenRetrievalResult) -> ()
