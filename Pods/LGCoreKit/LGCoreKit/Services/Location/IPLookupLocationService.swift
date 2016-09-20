//
//  IPLookupLocationService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 07/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum IPLookupLocationServiceError: ErrorType, CustomStringConvertible {
    case Network
    case Internal

    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        }
    }

    init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case .Scammer, .NotFound, .Forbidden, .Internal, .BadRequest, .Unauthorized, .Conflict, .UnprocessableEntity,
             .InternalServerError, .NotModified, .TooManyRequests, .UserNotVerified, .Other:
            self = .Internal
        }
    }
}

public typealias IPLookupLocationServiceResult = Result<LGLocationCoordinates2D, IPLookupLocationServiceError>
public typealias IPLookupLocationServiceCompletion = IPLookupLocationServiceResult -> Void

public protocol IPLookupLocationService {
    func retrieveLocationWithCompletion(completion: IPLookupLocationServiceCompletion?)
}
