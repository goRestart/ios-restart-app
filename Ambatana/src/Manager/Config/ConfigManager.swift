//
//  ConfigFileManager.swift
//  LGCoreKit
//
//  Created by Dídac on 06/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result
import LGCoreKit

class ConfigManager {

    static let sharedInstance: ConfigManager = ConfigManager()

    private let service : ConfigRetrieveService
    private let dao : ConfigDAO
    private let appCurrentVersion : String

    private var config: Config? {
        didSet {
            guard let quadKeyZoomLevel = config?.quadKeyZoomLevel else { return }
            LGCoreKit.quadKeyZoomLevel = quadKeyZoomLevel
        }
    }

    open var updateTimeout: Double    // seconds

    open var shouldForceUpdate: Bool {
        guard let actualConfig = config else {
            return false
        }
        for version in actualConfig.forceUpdateVersions {
            if String(version) == appCurrentVersion {
                return true
            }
        }
        return false
    }

    open var myMessagesCountForRating: Int {
        return config?.myMessagesCountForRating ?? Constants.myMessagesCountForRating
    }

    open var otherMessagesCountForRating: Int {
        return config?.otherMessagesCountForRating ?? Constants.otherMessagesCountForRating
    }


    // MARK: - Lifecycle

    public convenience init() {
        let configFileName = EnvironmentProxy.sharedInstance.configFileName
        let dao = LGConfigDAO(bundle: Bundle.main, configFileName: configFileName)
        self.init(dao: dao)
    }

    public convenience init(dao: ConfigDAO) {

        let config = dao.retrieve()
        let configURL = config?.configURL ?? EnvironmentProxy.sharedInstance.configURL

        let service = LGConfigRetrieveService(url: configURL)
        let appVersion = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? ""

        self.init(service: service, dao: dao, appCurrentVersion: appVersion)
    }

    public init(service: ConfigRetrieveService, dao: ConfigDAO, appCurrentVersion: String) {
        self.service = service
        self.dao = dao
        self.appCurrentVersion = appCurrentVersion

        self.config = dao.retrieve()
        self.updateTimeout = Constants.defaultConfigTimeOut
    }

    // MARK : - Public methods

    open func updateWithCompletion(_ completion: (() -> Void)?) {

        var didNotifyCompletion = false
        let delayTime = DispatchTime.now() + Double(Int64(updateTimeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if !didNotifyCompletion {
                didNotifyCompletion = true
                completion?()
            }
        }

        service.retrieveConfigWithCompletion { [weak self] (myResult: ConfigRetrieveServiceResult) -> Void in
            if let strongSelf = self {
                if let config = myResult.value {
                    // Update the in-memory file
                    strongSelf.config = config

                    // save the file to disk
                    strongSelf.dao.save(config)
                }
            }
            if !didNotifyCompletion {
                didNotifyCompletion = true
                completion?()
            }
        }
    }

    // MARK : - Private methods

    private func shouldForceUpdate(_ config: Config) -> (forceUpdate: Bool, suggestedUpdate: Bool) {
        for version in config.forceUpdateVersions {
            let versionNum = version
            if String(versionNum) == appCurrentVersion {
                return (true, true)
            }
        }
        return (false, false)
    }
}
