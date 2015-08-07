//
//  GoogleTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

struct GoogleConversionParams {
    let label: String
    let value: String
    let isRepeatable: Bool
    init(label: String, value: String, isRepeatable: Bool) {
        self.label = label
        self.value = value
        self.isRepeatable = isRepeatable
    }
}

private extension TrackerEvent {
    var gctParams: GoogleConversionParams? {
        get {
            switch name {
            case .ProductSellComplete:
                return GoogleConversionParams(label: "12NTCIbjvV4QzpfzxAM", value: "0.00", isRepeatable: true)
            default:
                return nil
            }
        }
    }
}

public class GoogleTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        ACTAutomatedUsageTracker.enableAutomatedUsageReportingWithConversionID(EnvironmentProxy.sharedInstance.googleConversionTrackingId)
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    public func setUser(user: User) {
        
    }
    
    public func trackEvent(event: TrackerEvent) {
        if let gctParams = event.gctParams {
            ACTConversionReporter.reportWithConversionID(EnvironmentProxy.sharedInstance.googleConversionTrackingId, label: gctParams.label, value: gctParams.value, isRepeatable: gctParams.isRepeatable)
        }
    }
}