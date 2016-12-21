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
    let appsFlyerAPIKey = "5EKnCjmwmNKjE2e7gYBo6T"
    let amplitudeAPIKey = ""
    
    // App indexing
    let googleAppIndexingId: UInt = 0
    
    // Google login
    let googleServerClientID = "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com"
    let googleClientID = "914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp.apps.googleusercontent.com"
    
    // Config
    let configFileName = "ios-prod"
    
    // Twitter
    let twitterConsumerKey = "krEbU50JQnxY9WkNp6zevuOpK"
    let twitterConsumerSecret = "QftWuBwJMb0UrfvGOErcIS6Oyf7d6RGn60HfN4DRLjgt7XmTgI"
    
    // Leanplum
    let leanplumAppId = ""
    let leanplumEnvKey = ""
    
    // Config
    var configURL = "https://escrow-images.s3.amazonaws.com/config/ios.json"
}
