//
//  EnvironmentProxy+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension EnvironmentProxy: AppEnvironment {

    // MARK: - AppEnvironment
    
    var appleAppId: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.appleAppId
    }
    
    var facebookAppId: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.facebookAppId
    }
    
    var appsFlyerAPIKey: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.appsFlyerAPIKey
    }
    
    var amplitudeAPIKey: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.amplitudeAPIKey
    }
    
    var googleConversionPrimaryTrackingId: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.googleConversionPrimaryTrackingId
    }
    
    var googleConversionSecondaryTrackingId: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.googleConversionSecondaryTrackingId
    }
    
    var nanigansAppId: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.nanigansAppId
    }
    
    var kahunaAPIKey: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.kahunaAPIKey
    }
    
    var newRelicToken: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.newRelicToken
    }
    
    var googleAppIndexingId: UInt {
        guard let appEnvironment = environment as? AppEnvironment else { return 0 }
        return appEnvironment.googleAppIndexingId
    }
    
    var configFileName: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.configFileName
    }
    
    var optimizelyAPIKey: String {
        guard let appEnvironment = environment as? AppEnvironment else { return "" }
        return appEnvironment.optimizelyAPIKey
    }
}
