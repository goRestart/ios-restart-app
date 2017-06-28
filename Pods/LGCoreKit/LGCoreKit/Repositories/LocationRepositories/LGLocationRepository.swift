//
//  CLLocationRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public class LGLocationRepository: LocationRepository {

    let dataSource: LocationDataSource

    // MARK: - Lifecycle

    public init(dataSource: LocationDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - PostalAddressRetrievalRepository

    public func retrieveAddressForLocation(_ searchText: String, completion: SuggestionsLocationRepositoryCompletion?) {

        dataSource.retrieveAddressForLocation(searchText) { (result) in
            if let value = result.value {
                completion?(SuggestionsLocationRepositoryResult(value: value))
                
            } else if let error = result.error {
                completion?(SuggestionsLocationRepositoryResult(error: error))
            }
        }
    }
    
    public func retrieveAddressForLocation(_ coordinates: LGLocationCoordinates2D, completion: PostalAddressLocationRepositoryCompletion?) {
        dataSource.retrieveAddressForLocation(coordinates) { (result) in
            if let value = result.value {
                completion?(PostalAddressLocationRepositoryResult(value: value))
                
            } else if let error = result.error {
                completion?(PostalAddressLocationRepositoryResult(error: error))
            }
        }
    }
    
    public func retrieveLocationWithCompletion(_ completion: IPLookupLocationRepositoryCompletion?) {
        dataSource.retrieveLocationWithCompletion { (result) in
            if let value = result.value {
                completion?(IPLookupLocationRepositoryResult(value: value))
                
            } else if let error = result.error {
                completion?(IPLookupLocationRepositoryResult(error: error))
            }
        }
    }
    
}
