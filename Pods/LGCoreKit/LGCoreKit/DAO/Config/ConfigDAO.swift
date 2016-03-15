//
//  ConfigDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 07/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol ConfigDAO {
    func retrieve() -> Config?
    func save(configFile: Config)
}


