//
//  CrashlyticsTracker.swift
//  LetGo
//
//  Created by Dídac on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Crashlytics

public class CrashlyticsTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        
    }
    
    public func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    public func setUser(user: MyUser?) {
        Crashlytics.sharedInstance().setUserEmail(user?.email)
        Crashlytics.sharedInstance().setUserIdentifier(user?.objectId)
        Crashlytics.sharedInstance().setUserName(user?.publicUsername)
    }
    

    public func trackEvent(event: TrackerEvent) {
        
    }
    
    public func updateCoordinates() {
        
    }
    
}