//
//  AmplitudeTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Amplitude_iOS
import LGCoreKit

final class AmplitudeTracker: Tracker {
    
    // Constants
    // > User properties
    private static let userPropIdKey = "user-id"
    private static let userPropEmailKey = "user-email"
    private static let userPropLatitudeKey = "user-lat"
    private static let userPropLongitudeKey = "user-lon"

    private static let userPropTypeKey = "UserType"
    private static let userPropTypeValueReal = "1"
    private static let userPropTypeValueDummy = "0"

    private static let userPropInstallationIdKey = "installation-id"

    // enabled permissions
    private static let userPropPushEnabled = "push-enabled"
    private static let userPropGpsEnabled = "gps-enabled"

    private static let userPropUserRating = "user-rating"

    // > Prefix
    private static let dummyEmailPrefix = "usercontent"

    // Login required tracking
    private var loggedIn = false
    private var pendingLoginEvent: TrackerEvent?
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        Amplitude.instance().trackingSessionEvents = false
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }

    func setInstallation(installation: Installation?) {
        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropInstallationIdKey, value: installation?.objectId ?? "")
        Amplitude.instance().identify(identify)
    }

    func setUser(user: MyUser?) {
        Amplitude.instance().setUserId(user?.email)

        var isDummy = false
        let dummyRange = (user?.email ?? "").rangeOfString(AmplitudeTracker.dummyEmailPrefix)
        if let isDummyRange = dummyRange where isDummyRange.startIndex == (user?.email ?? "").startIndex {
            isDummy = true
        }

        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropIdKey, value: user?.objectId ?? "")
        let userType = isDummy ? AmplitudeTracker.userPropTypeValueDummy : AmplitudeTracker.userPropTypeValueReal
        identify.set(AmplitudeTracker.userPropTypeKey, value: userType)
        identify.set(AmplitudeTracker.userPropUserRating, value: user?.ratingAverage)
        Amplitude.instance().identify(identify)

        loggedIn = user != nil
        if let pendingLoginEvent = pendingLoginEvent {
            trackEvent(pendingLoginEvent)
        }
    }
    
    func trackEvent(event: TrackerEvent) {
        switch event.name {
        case .LoginEmail, .LoginFB, .LoginGoogle, .SignupEmail:
            if loggedIn {
                Amplitude.instance().logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)
                pendingLoginEvent = nil
            } else {
                pendingLoginEvent = event
            }
        default:
            Amplitude.instance().logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)
        }
    }

    func setLocation(location: LGLocation?) {
        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropLatitudeKey, value: location?.coordinate.latitude)
        identify.set(AmplitudeTracker.userPropLongitudeKey, value: location?.coordinate.longitude)
        Amplitude.instance().identify(identify)
    }

    func setNotificationsPermission(enabled: Bool) {
        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropPushEnabled, value: enabled ? "true" : "false")
        Amplitude.instance().identify(identify)
    }

    func setGPSPermission(enabled: Bool) {
        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropGpsEnabled, value: enabled ? "true" : "false")
        Amplitude.instance().identify(identify)
    }
}
