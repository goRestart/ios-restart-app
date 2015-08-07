//
//  FacebookTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKCoreKit
import LGCoreKit

public class FacebookTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    public func setUser(user: User) {

    }
    
    public func trackEvent(event: TrackerEvent) {
        FBSDKAppEvents.logEvent(event.actualName, parameters: event.params?.stringKeyParams)
    }
}
