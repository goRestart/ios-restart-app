//
//  SessionManagerError.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 21/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


// MARK: - Public

public enum SessionManagerError: Error {

    case network
    case badRequest(cause: BadRequestCause)
    case notFound
    case forbidden
    case unauthorized
    case conflict(cause: ConflictCause)
    case scammer
    case nonExistingEmail
    case tooManyRequests
    case userNotVerified
    case internalError(message: String)
}


// MARK: - Internal

extension SessionManagerError {
    init(apiError: ApiError) {
        switch apiError {
        case .network:
            self = .network
        case .badRequest(let cause):
            self = .badRequest(cause: cause)
        case .unauthorized:
            self = .unauthorized
        case .notFound:
            self = .notFound
        case .forbidden:
            self = .forbidden
        case .conflict(let cause):
            self = .conflict(cause: cause)
        case .unprocessableEntity:
            self = .nonExistingEmail
        case .scammer:
            self = .scammer
        case .tooManyRequests:
            self = .tooManyRequests
        case .userNotVerified:
            self = .userNotVerified
        case .internalServerError:
            self = .internalError(message: "Internal Server Error")
        case let .internalError(description):
            self = .internalError(message: description)
        case let .other(httpCode):
            self = .internalError(message: "\(httpCode) HTTP code is not handled")
        case .notModified:
            self = .internalError(message: "Internal API Error")
        }
    }

    init(repositoryError: RepositoryError) {
        switch repositoryError {
        case .network:
            self = .network
        case .unauthorized:
            self = .unauthorized
        case .notFound:
            self = .notFound
        case .forbidden:
            self = .forbidden
        case .tooManyRequests:
            self = .tooManyRequests
        case .userNotVerified:
            self = .userNotVerified
        case let .internalError(message):
            self = .internalError(message: message)
        case .serverError:
            self = .internalError(message: "Internal Server Error")
        }
    }
}
