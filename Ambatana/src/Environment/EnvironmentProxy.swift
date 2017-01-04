//
//  EnvironmentProxy+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

enum AppEnvironmentType: String {
    case Development
    case Production
    case Escrow
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
        case .Development:
            environment = DevelopmentEnvironment()
        case .Production:
            environment = ProductionEnvironment()
        case .Escrow:
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

    var googleAppIndexingId: UInt {
        return environment.googleAppIndexingId
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

    var twitterConsumerKey: String {
        return environment.twitterConsumerKey
    }

    var twitterConsumerSecret: String {
        return environment.twitterConsumerSecret
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
}
