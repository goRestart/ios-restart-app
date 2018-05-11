//
//  AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

protocol AppEnvironment: AnalyticsAPIKeys {
    // General
    var appleAppId: String { get }
    var facebookAppId: String { get }

    // Google login
    var googleServerClientID: String { get }
    var googleClientID: String { get }

    // Config
    var configFileName: String { get }
    var configURL: String { get }

    // Website
    var websiteBaseUrl: String { get }
    var websiteBaseUrlWithLocaleParams: String { get }
    var websiteBaseUrlWithLanguageParam: String { get }

    // Google Ads
    var adTestModeActive: Bool { get }
    var moreInfoAdUnitIdDFP: String { get }
    var moreInfoAdUnitIdDFPUSA: String { get }
    var feedAdUnitIdDFPUSA10Ratio: String { get }
    var feedAdUnitIdDFPUSA15Ratio: String { get }
    var feedAdUnitIdDFPUSA20Ratio: String { get }
    var feedAdUnitIdAdxUSAForAllUsers: String { get }
    var feedAdUnitIdAdxUSAForOldUsers: String { get }
    
    // MoPub Ads
    var feedAdUnitIdMoPubUSAForAllUsers: String { get }
    var feedAdUnitIdMoPubUSAForOldUsers: String { get }
    var feedAdUnitIdMoPubTRForAllUsers: String { get }
    var feedAdUnitIdMoPubTRForOldUsers: String { get }
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

    var appsFlyerAppleAppId: String {
        return appleAppId
    }

    var leanplumAppId: String {
        return appleAppId
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
    
    func localizedLanguageUrl(_ language: String, endpoint: String) -> String {
        let format: String = websiteBaseUrlWithLanguageParam
        return String(format: format, arguments: [language]) + endpoint
    }
}
