//
//  ProductionEnvironment+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

class ProductionEnvironment: AppEnvironment {
    // General
    var appleAppId: String { get { return "986339882" } }
    var facebookAppId: String { get { return "699538486794082" } }
    
    // Tracking
    var appsFlyerAPIKey: String { get { return "5EKnCjmwmNKjE2e7gYBo6T" } }
    var amplitudeAPIKey: String { get { return "6d37fbd6c25243c57676e6d4ce7948bf" } }
    var gcPrimaryTrackingId: String { get { return "947998763" } }
    var gcSecondaryTrackingId: String { get { return "952362970" } }
    
    var kahunaAPIKey: String { get { return "9188e3c6b7cf47acb94a10ab027a08f3" } }
    
    // App indexing
    var googleAppIndexingId: UInt { get { return 986339882} }

    // Google login
    var googleServerClientID: String { return "914431496661-7s28hvdioe432kpco4lvh53frmkqlllv.apps.googleusercontent.com" }

    // Config
    var configFileName: String { get { return "ios-prod" } }
    
    // Twitter
    var twitterConsumerKey: String { get { return "krEbU50JQnxY9WkNp6zevuOpK" } }
    var twitterConsumerSecret: String { get { return "QftWuBwJMb0UrfvGOErcIS6Oyf7d6RGn60HfN4DRLjgt7XmTgI" } }

    // Taplytics
    var taplyticsApiKey: String { get { return "18371c3d3cebea738a848f901c5bedf04c5f9897" } }
}
