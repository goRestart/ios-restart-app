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
    var feedAdUnitIdDFPUSA10Ratio: String { get }
    var feedAdUnitIdDFPUSA15Ratio: String { get }
    var feedAdUnitIdDFPUSA20Ratio: String { get }
}

extension AppEnvironment {
    
    var amplitudeAPIKey: String {
        #if APP_STORE
            return "6d37fbd6c25243c57676e6d4ce7948bf"
        #else
            return "1c32ba5ed444237608436bad4f310307"
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
