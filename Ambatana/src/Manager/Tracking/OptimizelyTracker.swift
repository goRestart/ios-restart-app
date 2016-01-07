//
//  OptimizelyTracker.swift
//  LetGo
//
//  Created by Isaac Roldan on 19/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Optimizely

private extension TrackerEvent {
   
}

public class OptimizelyTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        Optimizely.startOptimizelyWithAPIToken(EnvironmentProxy.sharedInstance.optimizelyAPIKey, launchOptions:launchOptions)
        Optimizely.activateAmplitudeIntegration() // For this to work, Optimizely must be initiated after Amplitude!
    }
    
    public func setUser(user: MyUser?) {
        Optimizely.sharedInstance().userId = user?.objectId
    }
    
    public func trackEvent(event: TrackerEvent) {
        Optimizely.trackEvent(event.actualName)
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        Optimizely.refreshExperiments()
    }
    
    public func updateCoordinates() {
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
    }
    
    public func applicationDidEnterBackground(application: UIApplication) {
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
    }
}
