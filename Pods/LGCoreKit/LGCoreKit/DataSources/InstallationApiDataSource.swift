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

    static let sharedInstance = InstallationApiDataSource()

    /**
    Create an installation in the API from the given Installation object

    - parameter data:       Installation object with default values to create in API
    - parameter completion: Closure to call when the operation finishes
    */
    func create(params: [String: AnyObject], completion: ((Result<Installation, ApiError>) -> ())?) {
        let request = InstallationRouter.Create(params: params)
        ApiClient.request(request, decoder: self.decodeJson, completion: completion)
    }

    /**
    Update an installation in the API from the given parameters.
    If the given Installation doesn't have an objectId, the operation will fail

    - parameter data:       Installation object we want to update in the API
    - parameter completion: Closure to call when the operation finishes
    */
    func update(installationId: String, params: [String: AnyObject], completion: ((Result<Installation, ApiError>) -> ())?) {
        let request = InstallationRouter.Update(objectId: installationId, params: params)
        ApiClient.request(request, decoder: self.decodeJson, completion: completion)
    }

    /**
    Helper method to decode a JSON (AnyObject) to a LGInstallation (Installation protocol)

    - parameter jsonData: JSON with the Installation data

    - returns: Installation object (an LGInstallation instance)
    */
    private func decodeJson(jsonData: AnyObject) -> Installation? {
        let installation: LGInstallation? = decode(jsonData)
        return installation
    }
}
