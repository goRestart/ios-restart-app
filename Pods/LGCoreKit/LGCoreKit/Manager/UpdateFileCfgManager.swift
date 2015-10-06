//
//  UpdateFileCfgManager.swift
//  LGCoreKit
//
//  Created by Dídac on 06/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public class UpdateFileCfgManager {
    
    public private(set) var updateFileCfgService : UpdateFileCfgService
    public private(set) var updateFileCfgDAO : UpdateFileCfgDAO
    public private(set) var appCurrentVersion : String
    
    public var buildNumber : NSNumber
    public var forceUpdateVersions : NSMutableArray
    public var configURL : String

    // Singleton
    public static let sharedInstance: UpdateFileCfgManager = UpdateFileCfgManager()
    
    // MARK: - Lifecycle

    private convenience init() {
        
        let dao = LGUpdateFileCfgDAO()

        // if local file exists get URL from LOCAL file
        let localCfgFileURL = dao.getUpdateCfgFileFromBundle()?.configURL ?? ""

        let service = LGUpdateFileCfgService(url: localCfgFileURL)
        
        let appVersion = (NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String) ?? ""
        
        self.init(service: service, dao: dao, appCurrentVersion: appVersion)
        
    }
    
    public init(service: UpdateFileCfgService, dao: UpdateFileCfgDAO, appCurrentVersion: String) {
        self.buildNumber = 0
        self.forceUpdateVersions = []
        self.configURL = ""
        
        self.updateFileCfgDAO = dao
        self.updateFileCfgService = service
        
        self.appCurrentVersion = appCurrentVersion
    }
    
    // MARK : - Public methods

    public func getUpdateCfgFileFromServer(completion: ((Bool) -> Void)? ) {
        updateFileCfgService.retrieveCfgFileWithResult { [weak self] (myResult: Result<UpdateFileCfg, UpdateFileCfgServiceError>) -> Void in
            
            if let strongSelf = self {
                if let theFile = myResult.value {
                    var shouldUpdate = false
                    for version in theFile.forceUpdateVersions {
                        var versionNum = version as! NSNumber
                        if versionNum.stringValue == strongSelf.appCurrentVersion {
                            shouldUpdate = true
                        }
                    }
                    // save theFile on Disk
                    strongSelf.updateFileCfgDAO.saveUpdateCfgFileInBundle(theFile)
                    completion?(shouldUpdate)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
        }
    }

    public func getUpdateCfgFileFromBundle() -> UpdateFileCfg? {
        // call dao
        return updateFileCfgDAO.getUpdateCfgFileFromBundle()
    }

}
