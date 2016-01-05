//
//  EnvironmentProxy.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

public enum EnvironmentType: String {
    case Development = "-environment-dev", Production = "-environment-prod"     // Launch arguments
}

public class EnvironmentProxy: Environment {
    
    public static let sharedInstance = EnvironmentProxy()
    
    public private(set) var environment: Environment
    
    // MARK: - Lifecycle
    
    private init() {
        
        let envArgs = NSProcessInfo.processInfo().environment       
        if envArgs[EnvironmentType.Production.rawValue] != nil {
            environment = ProductionEnvironment()
        }
        else if envArgs[EnvironmentType.Development.rawValue] != nil {
            environment = DevelopmentEnvironment()
        }
        else {
            environment = ProductionEnvironment()
        }
    }
    
    // MARK: - Public methods
    
    public func setEnvironmentType(type: EnvironmentType) {
        switch type {
        case .Development:
            environment = DevelopmentEnvironment()
        case .Production:
            environment = ProductionEnvironment()
        }
    }
    
    // MARK: - Environment
    
    public var parseApplicationId: String { get { return environment.parseApplicationId } }
    public var parseClientId: String { get { return environment.parseClientId } }
    public var apiBaseURL: String { get { return environment.apiBaseURL } }
    public var bouncerBaseURL: String { get { return environment.bouncerBaseURL } }
    public var configURL: String { get { return environment.configURL } }
}