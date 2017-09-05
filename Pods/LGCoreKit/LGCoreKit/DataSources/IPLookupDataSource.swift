//
//  IPLookupDataSource.swift
//  LGCoreKit
//
//  Created by Nestor on 28/08/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result
import CoreLocation

public enum IPLookupLocationError: Error, CustomStringConvertible {
    case network
    case internalError
    
    public var description: String {
        switch self {
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

public typealias IPLookupLocationDataSourceResult = Result<LGLocationCoordinates2D, IPLookupLocationError>
public typealias IPLookupLocationDataSourceCompletion = (IPLookupLocationDataSourceResult) -> Void

public protocol IPLookupDataSource {
    func retrieveIPLookupLocation(completion: IPLookupLocationDataSourceCompletion?)
}
