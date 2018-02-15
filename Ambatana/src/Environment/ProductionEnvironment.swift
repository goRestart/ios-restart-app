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
    
    // Tracking
    let appsFlyerAPIKey = "5EKnCjmwmNKjE2e7gYBo6T"
    
    // Google login
    let googleServerClientID = "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com"
    let googleClientID = "914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp.apps.googleusercontent.com"

    // Config
    let configFileName = "ios-prod"
    let configURL = "https://cdn.letgo.com/config/ios.json"
    
    // Leanplum
    let leanplumAppId = "app_gYgnjLc98J3vIVHbmdD9W0Qwvy0A3KHMdo4PKd0zJD4"
    let leanplumEnvKey = "prod_OQEDqHOM3iZxZSKbcMuhnMZcee4PKDji5yJGfS5jn64"

    // Website
    let websiteBaseUrl = "https://www.letgo.com"
    let websiteBaseUrlWithLocaleParams = "https://%@.letgo.com/%@"

    // Google Ads
    let moreInfoAdUnitIdShopping = "partner-vert-pla-mobile-app-letgo-pdp"
    let moreInfoAdUnitIdShoppingUSA = "partner-vert-pla-mobile-app-letgo-us-pdp"
    let adTestModeActive = false
    let moreInfoAdUnitIdDFP = "/21636273254/turkey/iOS/moreinfo/320x100"
    let moreInfoAdUnitIdDFPUSA = "/21666124832/us/iOS/moreinfo/320x100"

    let feedAdUnitIdDFPUSA10Ratio = "/21666124832/us/iOS/feed/fluid_var_a"
    let feedAdUnitIdDFPUSA15Ratio = "/21666124832/us/iOS/feed/fluid_var_b"
    let feedAdUnitIdDFPUSA20Ratio = "/21666124832/us/iOS/feed/fluid_var_c"
}
