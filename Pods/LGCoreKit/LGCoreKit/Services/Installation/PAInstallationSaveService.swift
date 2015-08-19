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
    
    // MARK: - UserSaveService
    
    public func save(installation: Installation, result: InstallationSaveServiceResult?) {
        if let parseInstallation = installation as? PFInstallation {
            parseInstallation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    result?(Result<Installation, InstallationSaveServiceError>.success(parseInstallation))
                }
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<Installation, InstallationSaveServiceError>.failure(.Network))
                    default:
                        result?(Result<Installation, InstallationSaveServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<Installation, InstallationSaveServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<Installation, InstallationSaveServiceError>.failure(.Internal))
        }
    }
}
