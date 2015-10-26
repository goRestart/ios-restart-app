//
//  InstallationSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum InstallationSaveServiceError: ErrorType {
    case Network
    case Internal
}

public typealias InstallationSaveServiceResult = Result<Installation, InstallationSaveServiceError>
public typealias InstallationSaveServiceCompletion = InstallationSaveServiceResult -> Void

public protocol InstallationSaveService {
    
    /**
        Saves the installation.
    
        - parameter installation: The installation.
        - parameter completion: The completion closure.
    */
    func save(installation: Installation, completion: InstallationSaveServiceCompletion?)
}