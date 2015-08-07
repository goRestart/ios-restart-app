//
//  GoogleTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

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
    
    public func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    public func setUser(user: User) {
        
    }
    
    public func trackEvent(event: TrackerEvent) {
        if let gctParams = event.gctParams {
            ACTConversionReporter.reportWithConversionID(EnvironmentProxy.sharedInstance.googleConversionTrackingId, label: gctParams.label, value: gctParams.value, isRepeatable: gctParams.isRepeatable)
        }
    }
}