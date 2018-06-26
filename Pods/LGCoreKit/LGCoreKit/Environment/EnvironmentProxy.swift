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
    var realEstateBaseURL: String { return environment.realEstateBaseURL }
    var carsBaseURL: String { return environment.carsBaseURL }
    var servicesBaseURL: String { return environment.servicesBaseURL }
    var searchServicesBaseURL: String { return environment.searchServicesBaseURL }
    var bouncerBaseURL: String { return environment.bouncerBaseURL }
    var userRatingsBaseURL: String { return environment.userRatingsBaseURL }
    var chatBaseURL: String { return environment.chatBaseURL }
    var webSocketURL: String { return environment.webSocketURL }
    var notificationsBaseURL: String { return environment.notificationsBaseURL }
    var paymentsBaseURL: String { return environment.paymentsBaseURL }
    var suggestiveSearchBaseURL: String { return environment.suggestiveSearchBaseURL }
    var searchProductsBaseURL: String { return environment.searchProductsBaseURL }
    var searchRealEstateBaseURL: String { return environment.searchRealEstateBaseURL }
    var searchCarsBaseURL: String { return environment.searchCarsBaseURL }
    var niordBaseURL: String { return environment.niordBaseURL }
    var spellCorrectorBaseURL: String { return environment.spellCorrectorBaseURL }
    var meetingsBaseURL: String { return environment.meetingsBaseURL }
    var searchAlertsBaseURL: String { return environment.searchAlertsBaseURL }
    var customFeedBaseURL: String { return environment.customFeedBaseURL }
    var notificationSettingsPusherBaseURL: String { return environment.notificationSettingsPusherBaseURL }
    var notificationSettingsMailerBaseURL: String { return environment.notificationSettingsMailerBaseURL }
}
