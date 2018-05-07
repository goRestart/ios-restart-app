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
        case .serverError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified, .searchAlertError:
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
                return .internalError(description: "3000 - User not authenticated")
            case .userNotVerified:
                return .internalError(description: "6013 - User not verified")
            case .userBlocked:
                return .internalError(description: "3014 - User blocked")
            case let .internalError(message):
                return .internalError(description: message)
            case .differentCountry:
                return .internalError(description: "3013 - Users in different country")
            }
        }
    }
    
    var reportError: EventParameterProductReportError {
        switch self {
        case .network:
            return .network
        case .serverError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified, .wsChatError,
             .searchAlertError:
            return .serverError
        case .internalError:
            return .internalError
        }
    }
    
}
