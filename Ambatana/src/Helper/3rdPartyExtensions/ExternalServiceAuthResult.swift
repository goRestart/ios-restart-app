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
    case Success
    case Cancelled
    case Network
    case Forbidden
    case NotFound
    case Conflict(cause: ConflictCause)
    case Internal(description: String)
    
    init(sessionError: SessionManagerError) {
        switch sessionError {
        case .Conflict(let cause):
            self = .Conflict(cause: cause)
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
        case .Network:
            self = .Network
        case .NotFound:
            self = .NotFound
        case .Scammer:
            self = .Forbidden
        }
    }
}
