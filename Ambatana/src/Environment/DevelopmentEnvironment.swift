//
//  DevelopmentEnvironment+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class DevelopmentEnvironment: AppEnvironment {
    static let amplitudeKey = "1c32ba5ed444237608436bad4f310307"

    // General
    let appleAppId = "986339882"
    let facebookAppId = "924384130976182"
    
    // AppsFlyer
    let appsFlyerAPIKey = "5EKnCjmwmNKjE2e7gYBo6T"
    let oneLinkHost = "letgo.onelink.me"
    let oneLinkID = "O2PG"
    
    // Google login
    let googleServerClientID = "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com"
    let googleClientID = "914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp.apps.googleusercontent.com"

    // Config
    let configFileName = "ios-devel"
    let configURL = "https://letgo-images-devel.s3.amazonaws.com/mobile-config/ios.json"

    // Leanplum
    let leanplumAppId = "app_gYgnjLc98J3vIVHbmdD9W0Qwvy0A3KHMdo4PKd0zJD4"
    let leanplumEnvKey = "dev_4pEk10FFVnVlZLhlVAmV2yrM1M7huTZgLQMntH61dyk"

    // Website
    let websiteBaseUrl = "https://www.stg.letgo.com"
    let websiteBaseUrlWithLocaleParams = "https://%@.stg.letgo.com/%@"
    let websiteBaseUrlWithLanguageParam = "https://%@.stg.letgo.com"
    
    // Google Ads
    let adTestModeActive = true
    let moreInfoAdUnitIdDFP = "/21636273254/turkey/iOS/moreinfo/320x100"
    let moreInfoAdUnitIdDFPUSA = "/21666124832/us/iOS/moreinfo/320x100"

    let feedAdUnitIdDFPUSA10Ratio = "/21666124832/us/iOS/feed/fluid_var_a"
    let feedAdUnitIdDFPUSA15Ratio = "/21666124832/us/iOS/feed/fluid_var_b"
    let feedAdUnitIdDFPUSA20Ratio = "/21666124832/us/iOS/feed/fluid_var_c"
    
    var feedAdUnitIdAdxUSAForAllUsers = "/21666124832/us/iOS/feed/c_render_var_a"
    var feedAdUnitIdAdxUSAForOldUsers = "/21666124832/us/iOS/feed/c_render_var_b"
    var feedAdUnitIdAdxTRForAllUsers = "/21636273254/turkey/iOS/feed/c_render_var_a"
    var feedAdUnitIdAdxTRForOldUsers = "/21636273254/turkey/iOS/feed/c_render_var_b"
    
    // MoPub Ads
    let feedAdUnitIdMoPubUSAForAllUsers = "23d1d6db6b9848ba94f27887bb3585d2"
    let feedAdUnitIdMoPubUSAForOldUsers = "657d10ec0c1c48c3a280766a4dd821f4"
    let feedAdUnitIdMoPubTRForAllUsers = "05cf3847a6b24c389fc4127f595f5889"
    let feedAdUnitIdMoPubTRForOldUsers = "c6c5061b958949b0a90397d7346718aa"
    
}
