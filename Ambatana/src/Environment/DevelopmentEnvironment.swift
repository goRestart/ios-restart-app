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
    
    // Tracking
    let appsFlyerAPIKey = "5EKnCjmwmNKjE2e7gYBo6T"
    
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

    // Google Ads
    let moreInfoAdUnitIdShopping = "partner-vert-pla-mobile-app-letgo-pdp"
    let moreInfoAdUnitIdShoppingUSA = "partner-vert-pla-mobile-app-letgo-us-pdp"
    let adTestModeActive = true
    let moreInfoAdUnitIdDFP = "/21636273254/turkey/iOS/moreinfo/320x100"
    let moreInfoAdUnitIdDFPUSA = "/21666124832/us/iOS/moreinfo/320x100"

    let feedAdUnitIdDFPUSA10Ratio = "/21666124832/us/iOS/feed/fluid_var_a"
    let feedAdUnitIdDFPUSA15Ratio = "/21666124832/us/iOS/feed/fluid_var_b"
    let feedAdUnitIdDFPUSA20Ratio = "/21666124832/us/iOS/feed/fluid_var_c"
}
