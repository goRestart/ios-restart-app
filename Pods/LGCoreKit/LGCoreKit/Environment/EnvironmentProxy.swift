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
    case Escrow
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
        case .Escrow:
            environment = EscrowEnvironment()
        }
    }


    // MARK: - Environment

    var apiBaseURL: String { return environment.apiBaseURL }
    var bouncerBaseURL: String { return environment.bouncerBaseURL }
    var commercializerBaseURL: String { return environment.commercializerBaseURL }
    var userRatingsBaseURL: String { return environment.userRatingsBaseURL }
    var chatBaseURL: String { return environment.chatBaseURL }
    var webSocketURL: String { return environment.webSocketURL }
    var notificationsBaseURL: String { return environment.notificationsBaseURL }
}
