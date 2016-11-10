//
//  AmplitudeTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Amplitude_iOS
import LGCoreKit
import RxSwift

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

    // AB Tests
    private static let userPropABTests = "AB-test"

    private static let userPropMktPushNotificationKey = "marketing-push-notification"
    private static let userPropMktPushNotificationValueOn = "on"
    private static let userPropMktPushNotificationValueOff = "off"

    // > Prefix
    private static let dummyEmailPrefix = "usercontent"

    // Login required tracking
    private var loggedIn = false
    private var pendingLoginEvent: TrackerEvent?

    private let disposeBag = DisposeBag()
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        Amplitude.instance().trackingSessionEvents = false
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
        setupABTestsRx()
        setupMktNotificationsRx()
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
        let userId: String
        if let email = user?.email where !email.isEmpty {
            userId = email
        } else {
            userId = user?.objectId ?? ""
        }
        Amplitude.instance().setUserId(userId)

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


    // MARK: - Private

    private func setupABTestsRx() {
        ABTests.trackingData.asObservable().bindNext { trackingData in
            let identify = AMPIdentify()
            identify.set(AmplitudeTracker.userPropABTests, value: trackingData)
            Amplitude.instance().identify(identify)
        }.addDisposableTo(disposeBag)
    }

    private func setupMktNotificationsRx() {
        NotificationsManager.sharedInstance.loggedInMktNofitications.bindNext { enabled in
            let identify = AMPIdentify()
            let value = enabled ? AmplitudeTracker.userPropMktPushNotificationValueOn :
                AmplitudeTracker.userPropMktPushNotificationValueOff
            identify.set(AmplitudeTracker.userPropMktPushNotificationKey, value: value)
            Amplitude.instance().identify(identify)
        }.addDisposableTo(disposeBag)
    }
}
