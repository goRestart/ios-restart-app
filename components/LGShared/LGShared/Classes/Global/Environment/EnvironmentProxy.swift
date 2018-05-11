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
    
    var appsFlyerAppInviteOneLinkID: String {
        return environment.appsFlyerAppInviteOneLinkID
    }

    var amplitudeAPIKey: String {
        return environment.amplitudeAPIKey
    }

    var googleServerClientID: String {
        return environment.googleServerClientID
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
    
    var websiteBaseUrlWithLanguageParam: String {
        return environment.websiteBaseUrlWithLanguageParam
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

    var feedAdUnitIdDFPUSA10Ratio: String {
        return environment.feedAdUnitIdDFPUSA10Ratio
    }

    var feedAdUnitIdDFPUSA15Ratio: String {
        return environment.feedAdUnitIdDFPUSA15Ratio
    }

    var feedAdUnitIdDFPUSA20Ratio: String {
        return environment.feedAdUnitIdDFPUSA20Ratio
    }
    
    var feedAdUnitIdMoPubUSAForAllUsers: String {
        return environment.feedAdUnitIdMoPubUSAForAllUsers
    }
    
    var feedAdUnitIdMoPubUSAForOldUsers: String {
        return environment.feedAdUnitIdMoPubUSAForOldUsers
    }
    
    var feedAdUnitIdMoPubTRForAllUsers: String {
        return environment.feedAdUnitIdMoPubTRForAllUsers
    }
    
    var feedAdUnitIdMoPubTRForOldUsers: String {
        return environment.feedAdUnitIdMoPubTRForOldUsers
    }
    
    var feedAdUnitIdAdxUSAForAllUsers: String {
        return environment.feedAdUnitIdAdxUSAForAllUsers
    }
    
    var feedAdUnitIdAdxUSAForOldUsers: String {
        return environment.feedAdUnitIdAdxUSAForOldUsers
    }
    
}
