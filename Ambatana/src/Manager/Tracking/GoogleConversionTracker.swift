//
//  GoogleConversionTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

struct GoogleConversionParams {
    let trackingId: String
    let label: String
    let value: String
    let isRepeatable: Bool
    init(trackingId: String, label: String, value: String, isRepeatable: Bool) {
        self.trackingId = trackingId
        self.label = label
        self.value = value
        self.isRepeatable = isRepeatable
    }
}

private extension TrackerEvent {
    var gctParams: [GoogleConversionParams]? {
        get {
            switch name {
            case .ProductSellComplete:
                return [
                    GoogleConversionParams(trackingId: EnvironmentProxy.sharedInstance.gcPrimaryTrackingId,
                        label: "RErZCKHw414Qq6CFxAM", value: "0.00", isRepeatable: true),
                    GoogleConversionParams(trackingId: EnvironmentProxy.sharedInstance.gcSecondaryTrackingId,
                        label: "b5bQCNq38V8Q2s-PxgM", value: "0.00", isRepeatable: true)]
            default:
                return nil
            }
        }
    }
}

public class GoogleConversionTracker: Tracker {

    var googleConversionInstallParams: [GoogleConversionParams] {
        get {
            return [
                GoogleConversionParams(trackingId: EnvironmentProxy.sharedInstance.gcPrimaryTrackingId,
                    label: "tjkBCOnz414Qq6CFxAM", value: "0.00", isRepeatable: false),
                GoogleConversionParams(trackingId: EnvironmentProxy.sharedInstance.gcSecondaryTrackingId,
                    label: "z34BCPS_8V8Q2s-PxgM", value: "0.00", isRepeatable: false)]
        }
    }

    // MARK: - Tracker

    public func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
            ACTAutomatedUsageTracker
                .enableAutomatedUsageReportingWithConversionID(EnvironmentProxy.sharedInstance.gcPrimaryTrackingId)
            ACTAutomatedUsageTracker
                .enableAutomatedUsageReportingWithConversionID(EnvironmentProxy.sharedInstance.gcSecondaryTrackingId)

            // Track the install
            let gctParams = googleConversionInstallParams
            for gctParam in gctParams {
                ACTConversionReporter.reportWithConversionID(gctParam.trackingId, label: gctParam.label,
                    value: gctParam.value, isRepeatable: gctParam.isRepeatable)
            }

    }

    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
        annotation: AnyObject?) {

    }

    public func applicationDidBecomeActive(application: UIApplication) {

    }

    public func applicationDidEnterBackground(application: UIApplication) {

    }

    public func applicationWillEnterForeground(application: UIApplication) {

    }

    public func setInstallation(installation: Installation) {

    }

    public func setUser(user: MyUser?) {

    }

    public func trackEvent(event: TrackerEvent) {
        if let gctParams = event.gctParams {
            for gctParam in gctParams {
                ACTConversionReporter.reportWithConversionID(gctParam.trackingId, label: gctParam.label,
                    value: gctParam.value, isRepeatable: gctParam.isRepeatable)
            }
        }
    }
    
    public func updateCoordinates() {
        
    }

    public func notificationsPermissionChanged() {

    }

    public func gpsPermissionChanged() {
        
    }
}
