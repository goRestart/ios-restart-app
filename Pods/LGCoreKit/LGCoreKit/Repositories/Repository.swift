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
    case Unauthorized
    case Forbidden
    case TooManyRequests
    case UserNotVerified
    
    private static let NotModifiedMessage = "Not modified in API"

    public init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case let .Internal(description):
            self = .Internal(message: description)
        case .Unauthorized:
            self = .Unauthorized
        case .NotFound:
            self = .NotFound
        case .Forbidden:
            self = .Forbidden
        case .Conflict(let cause):
            self = .Internal(message: "Conflict with cause: \(cause)")
        case .Scammer:
            self = .Unauthorized
        case .UnprocessableEntity:
            self = .Internal(message: "Unprocessable Entity")
        case .TooManyRequests:
            self = .TooManyRequests
        case .UserNotVerified:
            self = .UserNotVerified
        case .InternalServerError:
            self = .Internal(message: "Internal Server Error")
        case .NotModified:
            self = .Internal(message: RepositoryError.NotModifiedMessage)
        case let .Other(httpCode):
            self = .Internal(message: "Unhandled \(httpCode) status code")
        }
    }
    
    init(webSocketError: WebSocketError) {
        switch webSocketError {
        case .NotAuthenticated:
            self = .Unauthorized
        case .Internal:
            self = .Internal(message: "")
        }
    }
}


extension RepositoryError {
    public func isNotModified() -> Bool {
        switch self {
        case .Internal(let message):
            return message == RepositoryError.NotModifiedMessage
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
