//
//  InstallationRespository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result
import KeychainSwift

public typealias InstallationResult = Result<Installation, RepositoryError>
public typealias InstallationCompletion = InstallationResult -> Void


public enum InstallationNotification: String {
    case Create = "InstallationRepository.Create"
}


public protocol InstallationRepository: class {

    // MARK: - Public methods

    /**
    Will try to fetch the Installation object from the local data source and return it if exists.
    If there is no object stored, means the installation doesn't exist and should be created
    */
    var installation: Installation? { get }

    /**
    Updates the installation push token.

    - parameter token:      New Push token to update in API
    - parameter completion: Closure to execute when the opeartion finishes
    */
    func updatePushToken(token: String, completion: ((Result<Installation, RepositoryError>) -> ())?)

}


protocol InternalInstallationRepository: InstallationRepository {

    var installationId: String { get }

    // MARK: - Internal methods

    /**
     Updates the installation if there are changes in app version, locale or time zone.
     - returns: If the update was performed.
     */
    func updateIfChanged() -> Bool

    /**
     Updates an installation with all parameters.

     Note: After an installation authentication we do not retrieve the full installation object. As potentially changes
     might have happened, then we upload the whole entity.

     - parameter completion: The completion closure.
     */
    func update(completion: ((Result<Installation, ApiError>) -> ())?)

    /**
     Create an Installation object in the API and save it in local if succeeded.

     - parameter completion: Completion Closure to call when the operation finishes. Could be a success or an error
     */
    func create(completion: ((Result<Installation, ApiError>) -> ())?)

    /**
     Deletes the `Installation` object locally.
     */
    func delete()
}


