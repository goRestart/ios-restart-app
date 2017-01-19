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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        Amplitude.instance().trackingSessionEvents = false
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
        setupABTestsRx()
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func setInstallation(_ installation: Installation?) {
        let identify = AMPIdentify()
        let installationValue = NSString(string: installation?.objectId ?? "")
        identify.set(AmplitudeTracker.userPropInstallationIdKey, value: installationValue)
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
        let dummyRange = (user?.email ?? "").range(of: AmplitudeTracker.dummyEmailPrefix)
        if let isDummyRange = dummyRange, isDummyRange.lowerBound == (user?.email ?? "").startIndex {
            isDummy = true
        }

        let identify = AMPIdentify()
        let userIdValue = NSString(string: user?.objectId ?? "")
        identify.set(AmplitudeTracker.userPropIdKey, value: userIdValue)
        let userType = isDummy ? AmplitudeTracker.userPropTypeValueDummy : AmplitudeTracker.userPropTypeValueReal
        let userTypeValue = NSString(string: userType)
        identify.set(AmplitudeTracker.userPropTypeKey, value: userTypeValue)
        let ratingAverageValue = NSNumber(value: user?.ratingAverage ?? 0)
        identify.set(AmplitudeTracker.userPropUserRating, value: ratingAverageValue)
        Amplitude.instance().identify(identify)

        loggedIn = user != nil
        if let pendingLoginEvent = pendingLoginEvent {
            trackEvent(pendingLoginEvent)
        }
    }
    
    func trackEvent(_ event: TrackerEvent) {
        switch event.name {
        case .loginEmail, .loginFB, .loginGoogle, .signupEmail:
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
        guard let location = location else { return }
        let identify = AMPIdentify()
        let latitude = NSNumber(value: location.coordinate.latitude)
        let longitude = NSNumber(value: location.coordinate.longitude)
        identify.set(AmplitudeTracker.userPropLatitudeKey, value: latitude)
        identify.set(AmplitudeTracker.userPropLongitudeKey, value: longitude)
        Amplitude.instance().identify(identify)
    }

    func setNotificationsPermission(_ enabled: Bool) {
        let identify = AMPIdentify()
        let enabledValue = NSString(string: enabled ? "true" : "false")
        identify.set(AmplitudeTracker.userPropPushEnabled, value: enabledValue)
        Amplitude.instance().identify(identify)
    }

    func setGPSPermission(_ enabled: Bool) {
        let identify = AMPIdentify()
        let enabledValue = NSString(string: enabled ? "true" : "false")
        identify.set(AmplitudeTracker.userPropGpsEnabled, value: enabledValue)
        Amplitude.instance().identify(identify)
    }

    func setMarketingNotifications(_ enabled: Bool) {
        let identify = AMPIdentify()
        let value = enabled ? AmplitudeTracker.userPropMktPushNotificationValueOn :
            AmplitudeTracker.userPropMktPushNotificationValueOff
        let valueNotifications = NSString(string: value)
        identify.set(AmplitudeTracker.userPropMktPushNotificationKey, value: valueNotifications)
        Amplitude.instance().identify(identify)
    }


    // MARK: - Private

    private func setupABTestsRx() {
        ABTests.trackingData.asObservable().bindNext { trackingData in
            guard let trackingData = trackingData else { return }
            let identify = AMPIdentify()
            let trackingDataValue = NSArray(array: trackingData)
            identify.set(AmplitudeTracker.userPropABTests, value: trackingDataValue)
            Amplitude.instance().identify(identify)
        }.addDisposableTo(disposeBag)
    }
}
