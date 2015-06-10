//
//  PAInstallationSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

final public class PAInstallationSaveService: InstallationSaveService {
    
    // MARK: - Lifecycle
    
    public init() {
        
    }
    
    // MARK: - UserSaveService
    
    public func save(installation: Installation, completion: InstallationSaveCompletion) {
        if let parseInstallation = installation as? PFInstallation {
            parseInstallation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                completion(success: success, error: error)
            }
        }
        else {
            completion(success: false, error: NSError(code: LGErrorCode.Internal))
        }
    }
}
