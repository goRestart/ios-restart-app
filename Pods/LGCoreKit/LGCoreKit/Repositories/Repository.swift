//
//  Repository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result


// MARK: - RepositoryError

public enum RepositoryError: ErrorType {
    
    case Internal(message: String)
    
    case Network
    case NotFound
    case Unauthorized(code: Int?)
    case Forbidden
    case TooManyRequests
    case UserNotVerified

    case ServerError(code: Int?)
    
    private static let NotModifiedCode = 304

    public init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case let .Internal(description):
            self = .Internal(message: description)
        case .BadRequest(let cause):
            self = .Internal(message: "Bad request with cause: \(cause)")
        case .Unauthorized:
            self = .Unauthorized(code: apiError.httpStatusCode)
        case .NotFound:
            self = .NotFound
        case .Forbidden:
            self = .Forbidden
        case .Scammer:
            self = .Unauthorized(code: apiError.httpStatusCode)
        case .TooManyRequests:
            self = .TooManyRequests
        case .UserNotVerified:
            self = .UserNotVerified
        case .Conflict, .UnprocessableEntity, .InternalServerError, .NotModified, .Other:
            self = .ServerError(code: apiError.httpStatusCode)
        }
    }
    
    init(webSocketError: WebSocketError) {
        switch webSocketError {
        case .NotAuthenticated:
            self = .Unauthorized(code: nil)
        case .Internal:
            self = .Internal(message: "")
        case .UserNotVerified:
            self = .UserNotVerified
        }
    }

    public var errorCode: Int? {
        switch self {
        case .Network, .Internal:
            return nil
        case let .Unauthorized(code):
            return code
        case .NotFound:
            return 404
        case .Forbidden:
            return 403
        case .UserNotVerified:
            return 424
        case .TooManyRequests:
            return 429
        case let .ServerError(code):
            return code
        }
    }
}


extension RepositoryError {
    public func isNotModified() -> Bool {
        switch self {
        case .ServerError(let code):
            return code == RepositoryError.NotModifiedCode
        default:
            return false
        }
    }
}


// MARK: - HOF

/**
Handles the given API result and executes a completion with a `RepositoryError`.
- parameter result: The result to handle.
- parameter success: A completion block that is executed only on successful result.
- parameter completion: A completion block that is executed on both successful & failure result.
*/
func handleApiResult<T>(result: Result<T, ApiError>, completion: ((Result<T, RepositoryError>) -> ())?) {
    handleApiResult(result, success: nil, failed: nil, completion: completion)
}

func handleApiResult<T>(result: Result<T, ApiError>,
    success: ((T) -> ())?,
    completion: ((Result<T, RepositoryError>) -> ())?) {
        handleApiResult(result, success: success, failed: nil, completion: completion)
}

func handleApiResult<T>(result: Result<T, ApiError>,
    success: ((T) -> ())?,
    failed: ((ApiError) -> ())?,
    completion: ((Result<T, RepositoryError>) -> ())?) {
        if let value = result.value {
            success?(value)
            completion?(Result<T, RepositoryError>(value: value))
        } else if let apiError = result.error {
            failed?(apiError)
            let error = RepositoryError(apiError: apiError)
            completion?(Result<T, RepositoryError>(error: error))
        }
}

func handleWebSocketResult<T>(result: Result<T, WebSocketError>, completion: ((Result<T, RepositoryError>) -> ())?) {
    handleWebSocketResult(result, success: nil, failed: nil, completion: completion)
}

func handleWebSocketResult<T>(result: Result<T, WebSocketError>,
    success: ((T) -> ())?,
    completion: ((Result<T, RepositoryError>) -> ())?) {
        handleWebSocketResult(result, success: success, failed: nil, completion: completion)
}

func handleWebSocketResult<T>(result: Result<T, WebSocketError>,
    success: ((T) -> ())?,
    failed: ((WebSocketError) -> ())?,
    completion: ((Result<T, RepositoryError>) -> ())?) {
        if let value = result.value {
            success?(value)
            completion?(Result<T, RepositoryError>(value: value))
        } else if let webSocketError = result.error {
            failed?(webSocketError)
            let webSocketError = RepositoryError(webSocketError: webSocketError)
            completion?(Result<T, RepositoryError>(error: webSocketError))
        }
}
