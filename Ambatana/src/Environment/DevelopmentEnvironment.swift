//
//  DevelopmentEnvironment+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class DevelopmentEnvironment: AppEnvironment {
    // General
    let appleAppId = "986339882"
    let facebookAppId = "924384130976182"
    
    // Tracking
    let appsFlyerAPIKey = "5EKnCjmwmNKjE2e7gYBo6T"
    let amplitudeAPIKey = "1c32ba5ed444237608436bad4f310307"
    
    // App indexing
    let googleAppIndexingId: UInt = 986339882

    // Google login
    let googleServerClientID = "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com"
    let googleClientID = "914431496661-h1lf5kd3g9g743sec3emns7qj9ei0hcp.apps.googleusercontent.com"

    // Config
    let configFileName = "ios-devel"
    
    // Twitter
    let twitterConsumerKey = "krEbU50JQnxY9WkNp6zevuOpK"
    let twitterConsumerSecret = "QftWuBwJMb0UrfvGOErcIS6Oyf7d6RGn60HfN4DRLjgt7XmTgI"

    // Leanplum
    let leanplumAppId = "app_gYgnjLc98J3vIVHbmdD9W0Qwvy0A3KHMdo4PKd0zJD4"
    let leanplumEnvKey = "dev_4pEk10FFVnVlZLhlVAmV2yrM1M7huTZgLQMntH61dyk"

    // Config
    var configURL = "https://letgo-images-devel.s3.amazonaws.com/config/ios.json"
}
