//
//  SessionManagerError.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 21/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


// MARK: - Public

public enum SessionManagerError: ErrorType {

    case Network
    case BadRequest(cause: BadRequestCause)
    case NotFound
    case Forbidden
    case Unauthorized
    case Conflict(cause: ConflictCause)
    case Scammer
    case NonExistingEmail
    case TooManyRequests
    case UserNotVerified
    case Internal(message: String)
}


// MARK: - Internal

extension SessionManagerError {
    init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case .BadRequest(let cause):
            self = .BadRequest(cause: cause)
        case .Unauthorized:
            self = .Unauthorized
        case .NotFound:
            self = .NotFound
        case .Forbidden:
            self = .Forbidden
        case .Conflict(let cause):
            self = .Conflict(cause: cause)
        case .UnprocessableEntity:
            self = .NonExistingEmail
        case .Scammer:
            self = .Scammer
        case .TooManyRequests:
            self = .TooManyRequests
        case .UserNotVerified:
            self = .UserNotVerified
        case .InternalServerError:
            self = .Internal(message: "Internal Server Error")
        case let .Internal(description):
            self = .Internal(message: description)
        case let .Other(httpCode):
            self = .Internal(message: "\(httpCode) HTTP code is not handled")
        case .NotModified:
            self = .Internal(message: "Internal API Error")
        }
    }

    init(repositoryError: RepositoryError) {
        switch repositoryError {
        case .Network:
            self = .Network
        case .Unauthorized:
            self = .Unauthorized
        case .NotFound:
            self = .NotFound
        case .Forbidden:
            self = .Forbidden
        case .TooManyRequests:
            self = .TooManyRequests
        case .UserNotVerified:
            self = .UserNotVerified
        case let .Internal(message):
            self = .Internal(message: message)
        case .ServerError:
            self = .Internal(message: "Internal Server Error")
        }
    }

    init(webSocketError: WebSocketError) {
        switch webSocketError {
        case .NotAuthenticated:
            self = .Unauthorized
        case .Internal:
            self = .Internal(message: "")
        case .UserNotVerified:
            self = .UserNotVerified
        }
    }
}
