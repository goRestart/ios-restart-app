//
//  InstallationSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol InstallationSaveService {
    
    /**
        Saves the installation.
    
        :param: installation The installation.
        :param: completion The completion closure.
    */
    func save(installation: Installation, completion: InstallationSaveCompletion)
}