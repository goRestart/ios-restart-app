//
//  RepositoryError+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension RepositoryError {
    var chatError: EventParameterChatError {
        switch self {
        case .network:
            return .network(code: nil)
        case .serverError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified:
            return .serverError(code: self.errorCode)
        case let .internalError(message):
            return .internalError(description: message)
        case let .wsChatError(chatRepositoryError):
            switch chatRepositoryError {
            case let .network(code, _):
                return .network(code: code)
            case let .apiError(code):
                return .serverError(code: code)
            case .notAuthenticated:
                return .internalError(description: "User not authenticated")
            case .userNotVerified:
                return .internalError(description: "User not verified")
            case .userBlocked:
                return .internalError(description: "User blocked")
            case let .internalError(message):
                return .internalError(description: message)
            }
        }
    }
}
