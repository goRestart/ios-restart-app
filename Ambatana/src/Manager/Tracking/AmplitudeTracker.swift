//
//  AmplitudeTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Amplitude_iOS
import LGCoreKit

public class AmplitudeTracker: Tracker {
    
    // Constants
    // > User properties
    private static let userPropTypeKey = "UserType"
    private static let userPropTypeValueReal = "Real"
    private static let userPropTypeValueDummy = "Dummy"
    
    // > Prefix
    private static let dummyEmailPrefix = "usercontent"
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        AppsFlyerTracker.sharedTracker().trackAppLaunch()
    }
    
    public func setUser(user: User) {
        let email = user.email
        Amplitude.instance().setUserId(email)

        let isDummy: Bool
        if let actualEmail = email {
            isDummy = startsWith(actualEmail, AmplitudeTracker.dummyEmailPrefix)
        }
        else {
            isDummy = false
        }
        var properties: [NSObject : AnyObject] = [:]
        properties[AmplitudeTracker.userPropTypeKey] = isDummy ? AmplitudeTracker.userPropTypeValueDummy : AmplitudeTracker.userPropTypeValueReal
        Amplitude.instance().setUserProperties(properties, replace: true)
    }
    
    public func trackEvent(event: TrackerEvent) {
        Amplitude.instance().logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)
    }
}
