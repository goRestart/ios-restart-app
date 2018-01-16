//
//  EnvironmentProxy+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

enum AppEnvironmentType: String {
    case development
    case production
    case escrow
}

class EnvironmentProxy: AppEnvironment {

    static let sharedInstance = EnvironmentProxy()

    private(set) var environment: AppEnvironment


    // MARK: - Lifecycle

    private init() {
        environment = ProductionEnvironment()
    }


    // MARK: - Public methods

    func setEnvironmentType(_ type: AppEnvironmentType) {
        switch type {
        case .development:
            environment = DevelopmentEnvironment()
        case .production:
            environment = ProductionEnvironment()
        case .escrow:
            environment = EscrowEnvironment()
        }
    }


    // MARK: - AppEnvironment

    var appleAppId: String {
        return environment.appleAppId
    }

    var facebookAppId: String {
        return environment.facebookAppId
    }

    var appsFlyerAPIKey: String {
        return environment.appsFlyerAPIKey
    }

    var amplitudeAPIKey: String {
        return environment.amplitudeAPIKey
    }

    var googleClientID: String {
        return environment.googleClientID
    }

    var configFileName: String {
        return environment.configFileName
    }

    var leanplumAppId: String {
        return environment.leanplumAppId
    }

    var leanplumEnvKey: String {
        return environment.leanplumEnvKey
    }

    var configURL: String {
        return environment.configURL
    }

    var websiteBaseUrl: String {
        return environment.websiteBaseUrl
    }

    var websiteBaseUrlWithLocaleParams: String {
        return environment.websiteBaseUrlWithLocaleParams
    }

    var moreInfoAdUnitIdShopping: String {
        return environment.moreInfoAdUnitIdShopping
    }

    var moreInfoAdUnitIdShoppingUSA: String {
        return environment.moreInfoAdUnitIdShoppingUSA
    }

    var adTestModeActive: Bool {
        return environment.adTestModeActive
    }

    var moreInfoAdUnitIdDFP: String {
        return environment.moreInfoAdUnitIdDFP
    }

    var moreInfoAdUnitIdDFPUSA: String {
        return environment.moreInfoAdUnitIdDFPUSA
    }
}
