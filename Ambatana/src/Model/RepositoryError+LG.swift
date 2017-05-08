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
            return .network
        case .serverError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified:
            return .serverError(code: self.errorCode)
        case let .internalError(message):
            return .internalError(description: message)
        }
    }
}
