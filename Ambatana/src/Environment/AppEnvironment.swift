//
//  AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

protocol AppEnvironment {
    // General
    var appleAppId: String { get }
    var facebookAppId: String { get }

    // Tracking
    var appsFlyerAPIKey: String { get }
    var amplitudeAPIKey: String { get }
    
    // Google login
    var googleServerClientID: String { get }
    var googleClientID: String { get }

    // Config
    var configFileName: String { get }
    var configURL: String { get }

    // Leanplum
    var leanplumAppId: String { get }
    var leanplumEnvKey: String { get }

    // Website
    var websiteBaseUrl: String { get }
    var websiteBaseUrlWithLocaleParams: String { get }

    // Google Ads
    var moreInfoAdUnitIdShopping: String { get }
    var moreInfoAdUnitIdShoppingUSA: String { get }
    var adTestModeActive: Bool { get }
    var moreInfoAdUnitIdDFP: String { get }
    var moreInfoAdUnitIdDFPUSA: String { get }
    
    // AppsFlyer
    var appsFlyerAPIKey: String { get }
    var oneLinkID: String { get }
}

extension AppEnvironment {
    
    var amplitudeAPIKey: String {
        // Why this default implementation: https://ambatana.atlassian.net/browse/ABIOS-2510
        #if GOD_MODE
            return DevelopmentEnvironment.amplitudeKey
        #else
            return ProductionEnvironment.amplitudeKey
        #endif
    }

    func websiteUrl(_ endpoint: String) -> String {
        return String(format: "\(websiteBaseUrl)\(endpoint)", arguments: [endpoint])
    }
    func localizedWebsiteUrl(_ country: String, language: String, endpoint: String? = nil) -> String {
        let format: String
        if let endpoint = endpoint {
            format = "\(websiteBaseUrlWithLocaleParams)\(endpoint)"
        } else {
            format = "\(websiteBaseUrlWithLocaleParams)"
        }
        return String(format: format, arguments: [country, language])
    }
}
