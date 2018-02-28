//
//  LGIPLookupDataSource.swift
//  LGCoreKit
//
//  Created by Nestor on 28/08/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

class LGIPLookupDataSource: IPLookupDataSource {
    
    private let apiClient: ApiClient
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - IPLookupDataSource
    
    func retrieveIPLookupLocation(completion: IPLookupLocationDataSourceCompletion?) {
        let request = IPLookupRouter.ipLookup
        apiClient.request(request, decoder: LGIPLookupDataSource.decoder) {
            (result: Result<LGLocationCoordinates2D, ApiError>) -> () in
            
            if let value = result.value {
                completion?(IPLookupLocationDataSourceResult(value: value))
            } else if let error = result.error {
                completion?(IPLookupLocationDataSourceResult(error: IPLookupLocationError(apiError: error)))
            }
        }
    }
    
    // MARK: - Helpers
    
    static func decoder(_ object: Any) -> LGLocationCoordinates2D? {
        guard let dict = object as? [String: Any],
            let latitude = dict["latitude"] as? Double,
            let longitude = dict["longitude"] as? Double else {
                logAndReportParseError(object: object, entity: .ipLookup,
                                       comment: "latitude and/or longitude key missing or value is/are not Double")
                return nil
        }
        return LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
    }
    
}
