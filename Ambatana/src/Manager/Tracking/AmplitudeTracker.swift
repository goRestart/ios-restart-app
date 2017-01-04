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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
        Amplitude.instance().trackingSessionEvents = false
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
        setupABTestsRx()
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject?) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func setInstallation(_ installation: Installation?) {
        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropInstallationIdKey, value: installation?.objectId as NSObject?? ?? "" as NSObject!)
        Amplitude.instance().identify(identify)
    }

    func setUser(_ user: MyUser?) {
        let userId: String
        if let email = user?.email, !email.isEmpty {
            userId = email
        } else {
            userId = user?.objectId ?? ""
        }
        Amplitude.instance().setUserId(userId)

        var isDummy = false
        let dummyRange = (user?.email ?? "").rangeOfString(AmplitudeTracker.dummyEmailPrefix)
        if let isDummyRange = dummyRange, isDummyRange.startIndex == (user?.email ?? "").startIndex {
            isDummy = true
        }

        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropIdKey, value: user?.objectId as NSObject?? ?? "" as NSObject!)
        let userType = isDummy ? AmplitudeTracker.userPropTypeValueDummy : AmplitudeTracker.userPropTypeValueReal
        identify.set(AmplitudeTracker.userPropTypeKey, value: userType as NSObject!)
        identify.set(AmplitudeTracker.userPropUserRating, value: user?.ratingAverage as NSObject!)
        Amplitude.instance().identify(identify)

        loggedIn = user != nil
        if let pendingLoginEvent = pendingLoginEvent {
            trackEvent(pendingLoginEvent)
        }
    }
    
    func trackEvent(_ event: TrackerEvent) {
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

    func setLocation(_ location: LGLocation?) {
        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropLatitudeKey, value: location?.coordinate.latitude as NSObject!)
        identify.set(AmplitudeTracker.userPropLongitudeKey, value: location?.coordinate.longitude as NSObject!)
        Amplitude.instance().identify(identify)
    }

    func setNotificationsPermission(_ enabled: Bool) {
        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropPushEnabled, value: enabled ? "true" : "false" as NSObject!)
        Amplitude.instance().identify(identify)
    }

    func setGPSPermission(_ enabled: Bool) {
        let identify = AMPIdentify()
        identify.set(AmplitudeTracker.userPropGpsEnabled, value: enabled ? "true" : "false" as NSObject!)
        Amplitude.instance().identify(identify)
    }

    func setMarketingNotifications(_ enabled: Bool) {
        let identify = AMPIdentify()
        let value = enabled ? AmplitudeTracker.userPropMktPushNotificationValueOn :
            AmplitudeTracker.userPropMktPushNotificationValueOff
        identify.set(AmplitudeTracker.userPropMktPushNotificationKey, value: value as NSObject!)
        Amplitude.instance().identify(identify)
    }


    // MARK: - Private

    private func setupABTestsRx() {
        ABTests.trackingData.asObservable().bindNext { trackingData in
            let identify = AMPIdentify()
            identify.set(AmplitudeTracker.userPropABTests, value: trackingData as NSObject!)
            Amplitude.instance().identify(identify)
        }.addDisposableTo(disposeBag)
    }
}
