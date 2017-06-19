//
//  LGCoreKitConfig.swift
//  LGCoreKit
//
//  Created by Dídac on 06/04/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public struct LGCoreKitConfig {

    public var environmentType: EnvironmentType
    public var shouldUseChatWithWebSocket: Bool
    public var carsInfoAppJSONURL: URL

    public init(environmentType: EnvironmentType, shouldUseChatWithWebSocket: Bool, carsInfoAppJSONURL: URL) {
        self.environmentType = environmentType
        self.shouldUseChatWithWebSocket = shouldUseChatWithWebSocket
        self.carsInfoAppJSONURL = carsInfoAppJSONURL
    }
}
