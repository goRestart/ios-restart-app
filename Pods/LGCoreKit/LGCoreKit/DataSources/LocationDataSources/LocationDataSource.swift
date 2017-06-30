//
//  LocationDataSource.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 26/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

public enum LocationError: Error {
    case network
    case internalError
    case notFound
}

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

public typealias SuggestionsLocationDataSourceResult = Result<[Place], LocationError>
public typealias SuggestionsLocationDataSourceCompletion = (SuggestionsLocationDataSourceResult) -> Void

public typealias PostalAddressLocationDataSourceResult = Result<Place, LocationError>
public typealias PostalAddressLocationDataSourceCompletion = (PostalAddressLocationDataSourceResult) -> Void

public typealias IPLookupLocationDataSourceResult = Result<LGLocationCoordinates2D, IPLookupLocationError>
public typealias IPLookupLocationDataSourceCompletion = (IPLookupLocationDataSourceResult) -> Void

public protocol LocationDataSource {
    func retrieveAddressForLocation(_ searchText: String, completion: SuggestionsLocationDataSourceCompletion?)
    func retrieveAddressForLocation(_ location: LGLocationCoordinates2D, completion: PostalAddressLocationDataSourceCompletion?)
    func retrieveLocationWithCompletion(_ completion: IPLookupLocationDataSourceCompletion?)
}
