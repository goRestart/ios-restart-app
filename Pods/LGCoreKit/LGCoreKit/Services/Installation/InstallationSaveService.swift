//
//  InstallationSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum InstallationSaveServiceError {
    case Network
    case Internal
}

public typealias InstallationSaveServiceResult = (Result<Installation, InstallationSaveServiceError>) -> Void

public protocol InstallationSaveService {
    
    /**
        Saves the installation.
    
        :param: installation The installation.
        :param: result The closure containing the result.
    */
    func save(installation: Installation, result: InstallationSaveServiceResult)
}