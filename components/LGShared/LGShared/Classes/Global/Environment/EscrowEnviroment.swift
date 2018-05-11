//
//  EscrowEnviroment.swift
//  LetGo
//
//  Created by Juan Iglesias on 30/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

class EscrowEnvironment: AppEnvironment {
    
    // General
    let appleAppId = "986339882"
    let facebookAppId = "699538486794082"
    
    // Tracking
    let amplitudeAPIKey = ""
    
    // AppsFlyer
    let appsFlyerAPIKey = "5EKnCjmwmNKjE2e7gYBo6T"
    let appsFlyerAppInviteOneLinkID = "O2PG"
    
    // Google login
    let googleServerClientID = "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com"
    let googleClientID = "914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp.apps.googleusercontent.com"
    
    // Config
    let configFileName = "ios-prod"
    let configURL = "https://escrow-images.s3.amazonaws.com/mobile-config/ios.json"
    
    
    // Leanplum
    let leanplumAppId = ""
    let leanplumEnvKey = ""

    // Website
    let websiteBaseUrl = "https://www.escrowverification.com"
    let websiteBaseUrlWithLocaleParams = "https://%@.escrowverification.com/%@"
    let websiteBaseUrlWithLanguageParam = "https://%@.escrowverification.com"
    
    // Google Ads
    let adTestModeActive = true
    let moreInfoAdUnitIdDFP = ""
    let moreInfoAdUnitIdDFPUSA = ""

    let feedAdUnitIdDFPUSA10Ratio = ""
    let feedAdUnitIdDFPUSA15Ratio = ""
    let feedAdUnitIdDFPUSA20Ratio = ""
    var feedAdUnitIdAdxUSAForAllUsers = ""
    var feedAdUnitIdAdxUSAForOldUsers = ""
    
    // MoPub Ads
    let feedAdUnitIdMoPubUSAForAllUsers = ""
    let feedAdUnitIdMoPubUSAForOldUsers = ""
    let feedAdUnitIdMoPubTRForAllUsers = ""
    let feedAdUnitIdMoPubTRForOldUsers = ""
    
}
