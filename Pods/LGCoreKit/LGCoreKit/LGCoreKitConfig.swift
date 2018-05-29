//
//  LGCoreKitConfig.swift
//  LGCoreKit
//
//  Created by Dídac on 06/04/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public struct LGCoreKitConfig {
    
    public var environmentType: EnvironmentType
    public var carsInfoAppJSONURL: URL
    public var taxonomiesAppJSONURL: URL
    public var servicesInfoAppJSONURL: URL

    public init(environmentType: EnvironmentType,
                carsInfoAppJSONURL: URL,
                taxonomiesAppJSONURL: URL,
                servicesInfoAppJSONURL: URL) {
        self.environmentType = environmentType
        self.carsInfoAppJSONURL = carsInfoAppJSONURL
        self.taxonomiesAppJSONURL = taxonomiesAppJSONURL
        self.servicesInfoAppJSONURL = servicesInfoAppJSONURL
    }
}
