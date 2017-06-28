//
//  LocationRepository.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result


public typealias SuggestionsLocationRepositoryResult = Result<[Place], LocationError>
public typealias SuggestionsLocationRepositoryCompletion = (SuggestionsLocationRepositoryResult) -> Void

public typealias PostalAddressLocationRepositoryResult = Result<Place, LocationError>
public typealias PostalAddressLocationRepositoryCompletion = (PostalAddressLocationRepositoryResult) -> Void

public typealias IPLookupLocationRepositoryResult = Result<LGLocationCoordinates2D, IPLookupLocationError>
public typealias IPLookupLocationRepositoryCompletion = (IPLookupLocationRepositoryResult) -> Void


public protocol LocationRepository {
    func retrieveAddressForLocation(_ searchText: String, completion: SuggestionsLocationRepositoryCompletion?)
    func retrieveAddressForLocation(_ location: LGLocationCoordinates2D, completion: PostalAddressLocationRepositoryCompletion?)
    func retrieveLocationWithCompletion(_ completion: IPLookupLocationRepositoryCompletion?)
}
