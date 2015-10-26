//
//  PAInstallationSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAInstallationSaveService: InstallationSaveService {
    
    // MARK: - Lifecycle
    
    public init() {
    }
    
    // MARK: - UserSaveService
    
    public func save(installation: Installation, completion: InstallationSaveServiceCompletion?) {
        if let parseInstallation = installation as? PFInstallation {
            parseInstallation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    completion?(InstallationSaveServiceResult(value: parseInstallation))
                }
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        completion?(InstallationSaveServiceResult(error: .Network))
                    default:
                        completion?(InstallationSaveServiceResult(error: .Internal))
                    }
                }
                else {
                    completion?(InstallationSaveServiceResult(error: .Internal))
                }
            }
        }
        else {
            completion?(InstallationSaveServiceResult(error: .Internal))
        }
    }
}
