//
//  LGInstallationRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import KeychainSwift
import RxSwift

class LGInstallationRepository: InternalInstallationRepository {

    let deviceIdDao: DeviceIdDAO
    let dao: InstallationDAO
    let dataSource: InstallationDataSource

    let appVersion: AppVersion
    let locale: NSLocale
    let timeZone: NSTimeZone

    var success: (Installation) -> ()


    // MARK: - Lifecycle

    init(deviceIdDao: DeviceIdDAO, dao: InstallationDAO, dataSource: InstallationDataSource,
         appVersion: AppVersion, locale: NSLocale, timeZone: NSTimeZone) {
        self.deviceIdDao = deviceIdDao
        self.dao = dao
        self.dataSource = dataSource

        self.appVersion = appVersion
        self.locale = locale
        self.timeZone = timeZone

        self.success = { installation in
            dao.save(installation)
        }
    }


    // MARK: - InstallationRepository methods

    /**
     Will try to fetch the Installation object from the local data source and return it if exists.
     If there is no object stored, means the installation doesn't exist and should be created
     */
    var installation: Installation? {
        return dao.installation
    }
    var rx_installation: Observable<Installation?> {
        return dao.rx_installation
    }

    var installationId: String {
        return installation?.objectId ?? deviceIdDao.deviceId
    }

    /**
     Updates the installation push token.

     - parameter token:      New Push token to update in API
     - parameter completion: Closure to execute when the opeartion finishes
     */
    func updatePushToken(token: String, completion: ((Result<Installation, RepositoryError>) -> ())?) {
        let JSONKeys = LGInstallation.ApiInstallationKeys()

        var params: [String: AnyObject] = [:]
        if let installation = installation {
            guard installation.deviceToken != token else {
                completion?(Result<Installation, RepositoryError>(value: installation))
                return
            }
        }
        params[JSONKeys.deviceToken] = token
        update(installationId, params: params) { result in
            if let installation = result.value {
                completion?(Result<Installation, RepositoryError>(value: installation))
            } else if let apiError = result.error {
                let error = RepositoryError(apiError: apiError)
                completion?(Result<Installation, RepositoryError>(error: error))
            }
        }
    }


    // MARK: - Internal methods

    /**
     Updates the installation if there are changes in app version, locale or time zone.
     - returns: If the update was performed.
     */
    func updateIfChanged() -> Bool {
        guard let installation = dao.installation else { return false }

        let params = buildInstallationUpdateParams(installation)
        guard !params.isEmpty else { return false }

        update(installationId, params: params, completion: nil)
        return true
    }

    /**
     Updates an installation with all parameters.

     Note: After an installation authentication we do not retrieve the full installation object. As potentially changes
     might have happened, then we upload the whole entity.

     - parameter completion: The completion closure.
     */
    func update(completion: ((Result<Installation, ApiError>) -> ())?) {
        let params = buildInstallationCreateParams()
        update(installationId, params: params, completion: completion)
    }

    /**
     Create an Installation object in the API and save it in local if succeeded.

     - parameter completion: Completion Closure to call when the operation finishes. Could be a success or an error
     */
    func create(completion: ((Result<Installation, ApiError>) -> ())?) {
        let params = buildInstallationCreateParams()
        create(params, completion: completion)
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

     - parameter installationId: The Installation id.
     - parameter params:         Dictionary containing the properties to be updated
     - parameter completion:     Closure to execute after completion
     */
    private func update(installationId: String, params: [String: AnyObject],
                        completion: ((Result<Installation, ApiError>) -> ())?) {
        dataSource.update(installationId, params: params) { [weak self] result in
            if let value = result.value {
                self?.success(value)
                completion?(Result<Installation, ApiError>(value: value))
            } else if let error = result.error {
                completion?(Result<Installation, ApiError>(error: error))
            }
        }
    }

    /**
     Builds Installation params for create.

     - returns: Installation params.
     */
    private func buildInstallationCreateParams() -> [String: AnyObject] {
        var dict = [String: AnyObject]()
        let JSONKeys = LGInstallation.ApiInstallationKeys()
        dict[JSONKeys.objectId] = deviceIdDao.deviceId
        dict[JSONKeys.appIdentifier] = NSBundle.mainBundle().bundleIdentifier ?? ""
        dict[JSONKeys.appVersion] = appVersion.shortVersionString
        dict[JSONKeys.deviceType] = "ios"
        dict[JSONKeys.timeZone] = timeZone.name
        dict[JSONKeys.localeIdentifier] = locale.localeIdentifier
        return dict
    }

    /**
     Builds Installation params for update. It only includes the differences with the given one.

     - parameter installation:  The installation to update from.
     - returns:                 Installation params.
     */
    private func buildInstallationUpdateParams(installation: Installation) -> [String: AnyObject] {
        let JSONKeys = LGInstallation.ApiInstallationKeys()
        var params: [String: AnyObject] = [:]
        if installation.appVersion != appVersion.shortVersionString {
            params[JSONKeys.appVersion] = appVersion.shortVersionString
        }
        if installation.localeIdentifier != locale.localeIdentifier {
            params[JSONKeys.localeIdentifier] = locale.localeIdentifier
        }
        if installation.timeZone != timeZone.name {
            params[JSONKeys.timeZone] = timeZone.name
        }
        return params
    }
}
