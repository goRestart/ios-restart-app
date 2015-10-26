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
       
        // Parse setup
        Parse.setApplicationId(EnvironmentProxy.sharedInstance.parseApplicationId, clientKey: EnvironmentProxy.sharedInstance.parseClientId)
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)

        let envArgs = NSProcessInfo.processInfo().environment
        if envArgs["test"] == nil {
            PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        }
        
        // Automatic anonymous user creation
        PFUser.enableAutomaticUser()
    }
}
