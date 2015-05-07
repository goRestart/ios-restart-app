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
        let arguments = NSProcessInfo.processInfo().arguments as NSArray
        if arguments.containsObject(EnvironmentType.Production.rawValue) {
            environment = ProductionEnvironment()
        }
        else if arguments.containsObject(EnvironmentType.Development.rawValue) {
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
    public var apiClientId: String { get { return environment.apiClientId } }
    public var apiClientSecret: String { get { return environment.apiClientSecret } }
}