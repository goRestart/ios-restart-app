//
//  InstallationStorage.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 02/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result
import Argo

class InstallationApiDataSource: InstallationDataSource {
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - Public methods
    
    /**
    Create an installation in the API from the given Installation object

    - parameter params:     Installation object with default values to create in API
    - parameter completion: Closure to call when the operation finishes
    */
    func create(_ params: [String: Any], completion: ((Result<Installation, ApiError>) -> ())?) {
        let request = InstallationRouter.create(params: params)
        apiClient.request(request, decoder: self.decodeJson, completion: completion)
    }

    /**
     Updates an installation in the API with the given parameters.

     - parameter installationId:    The Installation identifier.
     - parameter params:            The parameters to update in the Installation.
     - parameter completion:        Closure to call when the operation finishes
    */
    func update(_ installationId: String, params: [String: Any],
                completion: ((Result<Installation, ApiError>) -> ())?) {
        let request = InstallationRouter.patch(installationId: installationId, params: params)
        apiClient.request(request, decoder: self.decodeJson, completion: completion)
    }
    
    // MARK: - Private methods
    
    /**
    Helper method to decode a JSON (Any) to a LGInstallation (Installation protocol)

    - parameter jsonData: JSON with the Installation data

    - returns: Installation object (an LGInstallation instance)
    */
    private func decodeJson(_ jsonData: Any) -> Installation? {
        let installation: LGInstallation? = decode(jsonData)
        return installation
    }
}
