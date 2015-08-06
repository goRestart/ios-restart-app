//
//  AmplitudeTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Amplitude_iOS
import LGCoreKit

internal class AmplitudeTracker: Tracker {
    
    // Constants
    // > User properties
    internal static let userPropTypeKey = "UserType"
    internal static let userPropTypeValueReal = "Real"
    internal static let userPropTypeValueDummy = "Dummy"
    
    // > Prefix
    internal static let dummyEmailPrefix = "usercontent"
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        AppsFlyerTracker.sharedTracker().trackAppLaunch()
    }
    
    func setUser(user: User) {
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
    
    func trackEvent(event: TrackerEvent) {
        Amplitude.instance().logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)
    }
}
