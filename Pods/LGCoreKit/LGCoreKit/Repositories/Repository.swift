//
//  Repository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result


// MARK: - RepositoryError

public enum RepositoryError: Error, ApiErrorConvertible, WebSocketErrorConvertible {
    
    case internalError(message: String)
    case network(errorCode: Int, onBackground: Bool)
    case notFound
    case unauthorized(code: Int?)
    case forbidden(cause: ForbiddenCause)
    case tooManyRequests
    case userNotVerified

    case serverError(code: Int?)

    public init(apiError: ApiError) {
        switch apiError {
        case let .network(errorCode, onBackground):
            self = .network(errorCode: errorCode, onBackground: onBackground)
        case let .internalError(description):
            self = .internalError(message: description)
        case .badRequest(let cause):
            self = .internalError(message: "Bad request with cause: \(cause)")
        case .unauthorized:
            self = .unauthorized(code: apiError.httpStatusCode)
        case .notFound:
            self = .notFound
        case .forbidden(let cause):
            self = .forbidden(cause: cause)
        case .scammer:
            self = .unauthorized(code: apiError.httpStatusCode)
        case .tooManyRequests:
            self = .tooManyRequests
        case .userNotVerified:
            self = .userNotVerified
        case .conflict, .unprocessableEntity, .internalServerError, .notModified, .other:
            self = .serverError(code: apiError.httpStatusCode)
        }
    }
    
    init(webSocketError: WebSocketError) {
        switch webSocketError {
        case .notAuthenticated:
            self = .unauthorized(code: nil)
        case .internalError:
            self = .internalError(message: "")
        case .userNotVerified:
            self = .userNotVerified
        case .userBlocked:
            self = .forbidden(cause: .userBlocked)
        case .suspended(let code):
            self = .network(errorCode: code, onBackground: false)
        }
    }

    public var errorCode: Int? {
        switch self {
        case .network, .internalError:
            return nil
        case let .unauthorized(code):
            return code
        case .notFound:
            return 404
        case .forbidden:
            return 403
        case .userNotVerified:
            return 424
        case .tooManyRequests:
            return 429
        case let .serverError(code):
            return code
        }
    }
    
    public static func setupNetworkGenericError() -> RepositoryError {
        return .network(errorCode: 408, onBackground: false)
    }
}


extension RepositoryError {
    private static let notModifiedCode = 304
    
    public func isNotModified() -> Bool {
        switch self {
        case .serverError(let code):
            return code == RepositoryError.notModifiedCode
        default:
            return false
        }
    }
}

protocol ApiErrorConvertible {
    init(apiError: ApiError)
}

protocol WebSocketErrorConvertible {
    init(webSocketError: WebSocketError)
}


// MARK: - HOF

/**
Handles the given API result and executes a completion with a `RepositoryError`.
- parameter result: The result to handle.
- parameter success: A completion block that is executed only on successful result.
- parameter completion: A completion block that is executed on both successful & failure result.
*/
func handleApiResult<T, E: ApiErrorConvertible>(_ result: Result<T, ApiError>, completion: ((Result<T, E>) -> ())?) {
    handleApiResult(result, success: nil, failed: nil, completion: completion)
}

func handleApiResult<T, E: ApiErrorConvertible>(_ result: Result<T, ApiError>,
    success: ((T) -> ())?,
    completion: ((Result<T, E>) -> ())?) {
        handleApiResult(result, success: success, failed: nil, completion: completion)
}

func handleApiResult<T, E: ApiErrorConvertible>(_ result: Result<T, ApiError>,
    success: ((T) -> ())?,
    failed: ((ApiError) -> ())?,
    completion: ((Result<T, E>) -> ())?) {
        if let value = result.value {
            success?(value)
            completion?(Result<T, E>(value: value))
        } else if let apiError = result.error {
            failed?(apiError)
            let error = E.init(apiError: apiError)
            completion?(Result<T, E>(error: error))
        }
}

func handleWebSocketResult<T, E: WebSocketErrorConvertible>(_ result: Result<T, WebSocketError>,
                           completion: ((Result<T, E>) -> ())?) {
    handleWebSocketResult(result, success: nil, failed: nil, completion: completion)
}

func handleWebSocketResult<T, E: WebSocketErrorConvertible>(_ result: Result<T, WebSocketError>,
    success: ((T) -> ())?,
    completion: ((Result<T, E>) -> ())?) {
        handleWebSocketResult(result, success: success, failed: nil, completion: completion)
}

func handleWebSocketResult<T, E: WebSocketErrorConvertible>(_ result: Result<T, WebSocketError>,
    success: ((T) -> ())?,
    failed: ((WebSocketError) -> ())?,
    completion: ((Result<T, E>) -> ())?) {
        if let value = result.value {
            success?(value)
            completion?(Result<T, E>(value: value))
        } else if let webSocketError = result.error {
            failed?(webSocketError)
            let webSocketError = E.init(webSocketError: webSocketError)
            completion?(Result<T, E>(error: webSocketError))
        }
}
