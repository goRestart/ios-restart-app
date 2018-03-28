//
//  LocationDataSource.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 26/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation
import Result
import CoreLocation

public enum LocationError: Error {
    case network
    case internalError
    case notFound
}

public typealias SuggestionsLocationDataSourceResult = Result<[Place], LocationError>
public typealias SuggestionsLocationDataSourceCompletion = (SuggestionsLocationDataSourceResult) -> Void

public typealias LocationSuggestionDetailsDataSourceResult = Result<Place, LocationError>
public typealias SuggestionLocationDetailsDataSourceCompletion = (LocationSuggestionDetailsDataSourceResult) -> Void

public typealias PostalAddressLocationDataSourceResult = Result<Place, LocationError>
public typealias PostalAddressLocationDataSourceCompletion = (PostalAddressLocationDataSourceResult) -> Void

public protocol LocationDataSource {
    func retrieveLocationSuggestions(addressString: String,
                                     region: CLCircularRegion?,
                                     completion: SuggestionsLocationDataSourceCompletion?)
    func retrievePostalAddress(location: LGLocationCoordinates2D,
                               completion: PostalAddressLocationDataSourceCompletion?)
    func retrieveLocationSuggestionDetails(placeId: String,
                                           completion: SuggestionLocationDetailsDataSourceCompletion?)
}
