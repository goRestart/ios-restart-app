//
//  SessionService.swift
//  LGCoreKit
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

// MARK: - Completion block definitions

public typealias RetrieveTokenCompletion = (token: SessionToken?, error: LGError?) -> Void

// MARK: - Enums & Structs

public struct RetrieveTokenParams {
    private(set) var clientId: String
    private(set) var clientSecret: String
    public init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
}

// MARK: - SessionService

public protocol SessionService {
    func retrieveTokenWithParams(params: RetrieveTokenParams, completion: RetrieveTokenCompletion)
}
