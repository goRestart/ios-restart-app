//
//  ConfigFileManager.swift
//  LGCoreKit
//
//  Created by Dídac on 06/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public class ConfigManager {
    
    private let service : ConfigRetrieveService
    private let dao : ConfigDAO
    private let appCurrentVersion : String
    
    private var config: Config?

    public var updateTimeout: Double    // seconds
    
    public var shouldForceUpdate: Bool {
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

    // MARK: - Lifecycle

    public convenience init(dao: ConfigDAO) {
        
        let config = dao.retrieve()
        let configURL = config?.configURL ?? EnvironmentProxy.sharedInstance.configURL
        
        let service = LGConfigRetrieveService(url: configURL)
        let appVersion = (NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String) ?? ""
        
        self.init(service: service, dao: dao, appCurrentVersion: appVersion)
    }
    
    public init(service: ConfigRetrieveService, dao: ConfigDAO, appCurrentVersion: String) {
        self.service = service
        self.dao = dao
        self.appCurrentVersion = appCurrentVersion
        
        self.config = dao.retrieve()
        self.updateTimeout = LGCoreKitConstants.defaultConfigTimeOut
    }
    
    // MARK : - Public methods

    public func updateWithCompletion(completion: (() -> Void)?) {
        
        var didNotifyCompletion = false
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(updateTimeout * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
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
    
    private func shouldForceUpdate(config: Config) -> (forceUpdate: Bool, suggestedUpdate: Bool) {
        for version in config.forceUpdateVersions {
            let versionNum = version
            if String(versionNum) == appCurrentVersion {
                return (true, true)
            }
        }
        return (false, false)
    }
}
