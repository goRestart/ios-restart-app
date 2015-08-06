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

internal class GoogleTracker: Tracker {
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        ACTAutomatedUsageTracker.enableAutomatedUsageReportingWithConversionID(EnvironmentProxy.sharedInstance.googleConversionTrackingId)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    func setUser(user: User) {
        
    }
    
    func trackEvent(event: TrackerEvent) {
        if let gctParams = event.gctParams {
            ACTConversionReporter.reportWithConversionID(EnvironmentProxy.sharedInstance.googleConversionTrackingId, label: gctParams.label, value: gctParams.value, isRepeatable: gctParams.isRepeatable)
        }
    }
}
