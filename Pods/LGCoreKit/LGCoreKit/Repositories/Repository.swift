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
    

    public init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case .Internal:
            self = .Internal(message: "Internal API Error")
        case .Unauthorized:
            self = .Unauthorized
        case .NotFound:
            self = .NotFound
        case .AlreadyExists:
            self = .Internal(message: "Already Exists in API")
        case .Scammer:
            self = .Unauthorized
        case .InternalServerError:
            self = .Internal(message: "Internal Server Error")
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
