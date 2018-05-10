//
//  ProductionEnvironment+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class ProductionEnvironment: AppEnvironment {
    
    static let amplitudeKey = "6d37fbd6c25243c57676e6d4ce7948bf"
    
    // General
    let appleAppId = "986339882"
    let facebookAppId = "699538486794082"
    
    // AppsFlyer
    let appsFlyerAPIKey = "5EKnCjmwmNKjE2e7gYBo6T"
    let oneLinkHost = "letgo.onelink.me"
    let oneLinkID = "O2PG"

    // Google login
    let googleServerClientID = "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com"
    let googleClientID = "914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp.apps.googleusercontent.com"

    // Config
    let configFileName = "ios-prod"
    let configURL = "https://static.letgo.com/mobile-config/ios.json"
    
    // Leanplum
    let leanplumAppId = "app_gYgnjLc98J3vIVHbmdD9W0Qwvy0A3KHMdo4PKd0zJD4"
    let leanplumEnvKey = "prod_OQEDqHOM3iZxZSKbcMuhnMZcee4PKDji5yJGfS5jn64"

    // Website
    let websiteBaseUrl = "https://www.letgo.com"
    let websiteBaseUrlWithLocaleParams = "https://%@.letgo.com/%@"
    
    // Google Ads
    let adTestModeActive = false
    let moreInfoAdUnitIdDFP = "/21636273254/turkey/iOS/moreinfo/320x100"
    let moreInfoAdUnitIdDFPUSA = "/21666124832/us/iOS/moreinfo/320x100"

    let feedAdUnitIdDFPUSA10Ratio = "/21666124832/us/iOS/feed/fluid_var_a"
    let feedAdUnitIdDFPUSA15Ratio = "/21666124832/us/iOS/feed/fluid_var_b"
    let feedAdUnitIdDFPUSA20Ratio = "/21666124832/us/iOS/feed/fluid_var_c"
    
    var feedAdUnitIdAdxUSAForAllUsers = "/21666124832/us/iOS/feed/c_render_var_a"
    var feedAdUnitIdAdxUSAForOldUsers = "/21666124832/us/iOS/feed/c_render_var_b"
    
    // MoPub Ads
    let feedAdUnitIdMoPubUSAForAllUsers = "23d1d6db6b9848ba94f27887bb3585d2"
    let feedAdUnitIdMoPubUSAForOldUsers = "657d10ec0c1c48c3a280766a4dd821f4"
    let feedAdUnitIdMoPubTRForAllUsers = "05cf3847a6b24c389fc4127f595f5889"
    let feedAdUnitIdMoPubTRForOldUsers = "c6c5061b958949b0a90397d7346718aa"
    
}
