//
//  EnvironmentProxy.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

public enum EnvironmentType: String {
    case Staging
    case Canary
    case Production
}

class EnvironmentProxy: Environment {

    static let sharedInstance = EnvironmentProxy()

    private(set) var environment: Environment


    // MARK: - Lifecycle

    private init() {
        environment = ProductionEnvironment()
    }


    // MARK: - Public methods

    func setEnvironmentType(type: EnvironmentType) {
        switch type {
        case .Staging:
            environment = StagingEnvironment()
        case .Canary:
            environment = CanaryEnvironment()
        case .Production:
            environment = ProductionEnvironment()
        }
    }


    // MARK: - Environment

    var parseApplicationId: String { get { return environment.parseApplicationId } }
    var parseClientId: String { get { return environment.parseClientId } }
    var apiBaseURL: String { get { return environment.apiBaseURL } }
    var bouncerBaseURL: String { get { return environment.bouncerBaseURL } }
    var configURL: String { get { return environment.configURL } }
}
