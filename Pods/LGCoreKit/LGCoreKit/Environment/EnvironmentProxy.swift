//
//  EnvironmentProxy.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

public enum EnvironmentType: String {
    case staging
    case canary
    case production
    case escrow
}

class EnvironmentProxy: Environment {

    static let sharedInstance = EnvironmentProxy()

    private(set) var environment: Environment


    // MARK: - Lifecycle

    private init() {
        environment = ProductionEnvironment()
    }


    // MARK: - Public methods

    func setEnvironmentType(_ type: EnvironmentType) {
        switch type {
        case .staging:
            environment = StagingEnvironment()
        case .canary:
            environment = CanaryEnvironment()
        case .production:
            environment = ProductionEnvironment()
        case .escrow:
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
    var passiveBuyersBaseURL: String { return environment.passiveBuyersBaseURL }
    var paymentsBaseURL: String { return environment.paymentsBaseURL }
    var suggestiveSearchesBaseURL: String { return environment.suggestiveSearchesBaseURL }
}
