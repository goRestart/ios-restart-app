//
//  LGIPLookupLocationService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Result

final public class LGIPLookupLocationService: IPLookupLocationService {
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - Public methods
    
    public func retrieveLocationWithCompletion(_ completion: IPLookupLocationServiceCompletion?) {

        let request = LocationRouter.ipLookup
        apiClient.request(request, decoder: LGIPLookupLocationService.decoder) {
            (result: Result<LGLocationCoordinates2D, ApiError>) -> () in

            if let value = result.value {
                completion?(IPLookupLocationServiceResult(value: value))
            } else if let error = result.error {
                completion?(IPLookupLocationServiceResult(error: IPLookupLocationServiceError(apiError: error)))
            }
        }
    }

    static func decoder(_ object: Any) -> LGLocationCoordinates2D? {
        guard let theLocation : LGLocationCoordinates2D = LGArgo.jsonToCoordinates(JSON(object),
            latKey: "latitude", lonKey: "longitude").value else {
                return nil
        }
        return theLocation
    }
}
