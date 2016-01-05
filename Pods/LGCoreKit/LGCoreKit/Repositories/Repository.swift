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
    case Api(error: ApiError)
    case Internal
   
    init(apiError: ApiError) {
        self = .Api(error: apiError)
    }
}

extension RepositoryError: Equatable {}
public func ==(lhs: RepositoryError, rhs: RepositoryError) -> Bool {
    switch (lhs, rhs) {
    case (let .Api(lError), let .Api(rError)):
        return lError == rError
    case (.Api(_), .Internal), (.Internal, .Api(_)):
        return false
    case (.Internal, .Internal):
        return true
    }
}


// MARK: - HOF

/**
Handles the given API result and executes a completion with a `RepositoryError`.
- parameter result: The result to handle.
- parameter success: A completion block that is executed only on successful result.
- parameter completion: A completion block that is executed on both successful & failure result.
*/
func handleApiResult<T>(result: Result<T, ApiError>,
    success: ((T) -> ())?,
    completion: ((Result<T, RepositoryError>) -> ())?) {
        if let value = result.value {
            success?(value)
            completion?(Result<T, RepositoryError>(value: value))
        } else if let apiError = result.error {
            let error = RepositoryError(apiError: apiError)
            completion?(Result<T, RepositoryError>(error: error))
        }
}
