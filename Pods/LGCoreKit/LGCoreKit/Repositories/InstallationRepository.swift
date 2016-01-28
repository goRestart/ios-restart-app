//
//  InstallationRespository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result
import KeychainSwift

public class InstallationRepository {

    let deviceIdDao: DeviceIdDAO
    let dao: InstallationDAO
    let dataSource: InstallationDataSource

    var success: (Installation) -> ()


    // MARK: - Lifecycle

    init(deviceIdDao: DeviceIdDAO, dao: InstallationDAO, dataSource: InstallationDataSource) {
        self.deviceIdDao = deviceIdDao
        self.dao = dao
        self.dataSource = dataSource
        self.success = { installation in
            dao.save(installation)
        }
    }


    // MARK: - Public methods

    /**
    Will try to fetch the Installation object from the local data source and return it if exists.
    If there is no object stored, means the installation doesn't exist and should be created
    */
    public var installation: Installation? {
        return dao.installation
    }

    /**
    Update the installation push token.
    NOTE: This method will update the whole Installation in API doing a POST request, not a PATCH one.

    - parameter token:      New Push token to update in API
    - parameter completion: Closure to execute when the opeartion finishes
    */
    public func updatePushToken(token: String, completion: ((Result<Installation, RepositoryError>) -> ())?) {
        var dict = buildInstallation()

        if let installation = dao.installation {
            if installation.deviceToken == token {
                completion?(Result<Installation, RepositoryError>(value: installation))
                return
            }
            dict = buildInstallation(installation)
        }

        dict[LGInstallation.ApiInstallationKeys().deviceToken] = token
        update(dict, completion: completion)
    }


    // MARK: - Internal methods

    /**
    Create an Installation object in the API and save it in local if succeeded.

    - parameter completion: Completion Closure to call when the operation finishes. Could be a success or an error
    */
    func create(completion: ((Result<Installation, ApiError>) -> ())?) {
        let installation = buildInstallation()
        create(installation, completion: completion)
    }

    /**
    Deletes the `Installation` object locally.
    */
    func delete() {
        dao.delete()
    }


    // MARK: - Private methods

    /**
    Create a new installation with the given dictionary of parameters. The dictionary should include the
    minimum required parameters for this operation to work.

    Remember that doing a `create` to an existing object, will overwrite the existing one.

    - parameter installation: Dictionary of parameters to create the Installation
    - parameter completion:   Closure to execute when the operation finishes
    */
    private func create(installation: [String: AnyObject], completion: ((Result<Installation, ApiError>) -> ())?) {
        dataSource.create(installation) { [weak self] result in
            if let value = result.value {
                self?.success(value)
                completion?(Result<Installation, ApiError>(value: value))
            } else if let error = result.error {
                completion?(Result<Installation, ApiError>(error: error))
            }
        }
    }

    /**
    Update the current installation with the given parameters.
    This method will do a POST request, not a PATCH, so it needs to include all the basic parameters of the
    installation updating the ones you want to change in the API.

    - parameter installation: Dictionary with all the keys to overwrite in API (missing keys will be nil)
    - parameter completion:   Closure to execute after completion
    */
    private func update(installation: [String: AnyObject], completion:  ((Result<Installation, RepositoryError>) -> ())?) {
        create(installation) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }

    /**
    Build an Installation from scratch with default values.

    - returns: Installation Object
    */
    private func buildInstallation() -> [String: AnyObject] {

        let bundle = NSBundle.mainBundle().bundleIdentifier ?? ""
        let appVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as? String ?? ""

        var dict = [String: AnyObject]()
        let JSONKeys = LGInstallation.ApiInstallationKeys()
        dict[JSONKeys.objectId] = deviceIdDao.deviceId
        dict[JSONKeys.appIdentifier] = bundle
        dict[JSONKeys.appVersion] = appVersion
        dict[JSONKeys.deviceType] = "ios"
        dict[JSONKeys.timeZone] = NSTimeZone.systemTimeZone().name
        dict[JSONKeys.localeIdentifier] = NSLocale.localeIdString()

        return dict
    }

    private func buildInstallation(fromInstallation: Installation) -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        let JSONKeys = LGInstallation.ApiInstallationKeys()
        dict[JSONKeys.objectId] = fromInstallation.objectId
        dict[JSONKeys.appIdentifier] = fromInstallation.appIdentifier
        dict[JSONKeys.appVersion] = fromInstallation.appVersion
        dict[JSONKeys.deviceType] = fromInstallation.deviceType
        dict[JSONKeys.timeZone] = fromInstallation.timeZone
        dict[JSONKeys.localeIdentifier] = fromInstallation.localeIdentifier
        dict[JSONKeys.deviceToken] = fromInstallation.deviceToken

        return dict
    }
}
