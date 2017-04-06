//
//  InstallationDataSource.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

protocol InstallationDataSource {
    func create(_ params: [String: Any], completion: ((Result<Installation, ApiError>) -> ())?)
    func update(_ installationId: String, params: [String: Any],
                completion: ((Result<Installation, ApiError>) -> ())?)
}
