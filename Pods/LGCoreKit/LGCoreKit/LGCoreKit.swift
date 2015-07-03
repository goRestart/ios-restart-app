//
//  LGCoreKit.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import ParseFacebookUtilsV4

public class LGCoreKit {
    public static func initialize(launchOptions: [NSObject: AnyObject]?) {
        
        // Parse
        // > Register subclasses
        PAProduct.registerSubclass()
        
        // > Setup
        Parse.setApplicationId(EnvironmentProxy.sharedInstance.parseApplicationId, clientKey: EnvironmentProxy.sharedInstance.parseClientId)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        // > Automatic anonymous user creation
        PFUser.enableAutomaticUser()
        
        // Shared instances
        MyUserManager.sharedInstance
    }
}
