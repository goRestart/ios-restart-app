//
//  IPLookupLocationService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 07/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum IPLookupLocationServiceError: Error, CustomStringConvertible {
    case network
    case internalError

    public var description: String {
        switch (self) {
        case .network:
            return "Network"
        case .internalError:
            return "Internal"
        }
    }

    init(apiError: ApiError) {
        switch apiError {
        case .network:
            self = .network
        case .scammer, .notFound, .forbidden, .internalError, .badRequest, .unauthorized, .conflict, .unprocessableEntity,
             .internalServerError, .notModified, .tooManyRequests, .userNotVerified, .other:
            self = .internalError
        }
    }
}

public typealias IPLookupLocationServiceResult = Result<LGLocationCoordinates2D, IPLookupLocationServiceError>
public typealias IPLookupLocationServiceCompletion = (IPLookupLocationServiceResult) -> Void

public protocol IPLookupLocationService {
    func retrieveLocationWithCompletion(_ completion: IPLookupLocationServiceCompletion?)
}
