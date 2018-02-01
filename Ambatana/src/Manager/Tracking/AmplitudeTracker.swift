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
    private static let userPropCountryCodeKey = "user-country-code"

    private static let userPropTypeKey = "UserType"
    private static let userPropTypeValueReal = "1"
    private static let userPropTypeValueDummy = "0"

    private static let userPropInstallationIdKey = "installation-id"

    // enabled permissions
    private static let userPropPushEnabled = "push-enabled"
    private static let userPropGpsEnabled = "gps-enabled"

    private static let userPropUserRating = "user-rating"

    // AB Tests
    private static let userPropABTestsCore = "AB-test-core"
    private static let userPropABTestsRealEstate = "AB-test-realEstate"
    private static let userPropABTestsMoney = "AB-test-money"
    private static let userPropABTestsRetention = "AB-test-retention"
    private static let userPropABTestsRetention = "AB-test-chat"
    
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
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
                     featureFlags: FeatureFlaggeable) {
        Amplitude.instance().trackingSessionEvents = false
        Amplitude.instance().initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
        setupABTestsRx(featureFlags: featureFlags)
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
        Amplitude.instance().setUserId(user?.emailOrId)

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

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {
        guard let location = location else { return }
        let identify = AMPIdentify()
        let latitude = NSNumber(value: location.coordinate.latitude)
        let longitude = NSNumber(value: location.coordinate.longitude)
        identify.set(AmplitudeTracker.userPropLatitudeKey, value: latitude)
        identify.set(AmplitudeTracker.userPropLongitudeKey, value: longitude)
        if let countryCode = postalAddress?.countryCode {
            let countryObject = NSString(string: countryCode)
            identify.set(AmplitudeTracker.userPropCountryCodeKey, value: countryObject)
        }
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

    private func setupABTestsRx(featureFlags: FeatureFlaggeable) {
        featureFlags.trackingData.asObservable().bind { trackingData in
            guard let trackingData = trackingData else { return }
            var coreAbtests: [String] = []
            var moneyAbTests: [String] = []
            var realEstateAbTests: [String] = []
            var retentionAbTests: [String] = []
            var chatAbTests: [String] = []
            trackingData.forEach({ (identifier, abGroupType) in
                switch abGroupType {
                case .core:
                    coreAbtests.append(identifier)
                case .money:
                    moneyAbTests.append(identifier)
                case .realEstate:
                    realEstateAbTests.append(identifier)
                case .retention:
                    retentionAbTests.append(identifier)
                case .chat:
                    chatAbTests.append(identifier)
                }
            })
            let dict: [String: [String]] = [AmplitudeTracker.userPropABTestsCore: coreAbtests,
                                                 AmplitudeTracker.userPropABTestsMoney: moneyAbTests,
                                                 AmplitudeTracker.userPropABTestsRealEstate: realEstateAbTests,
                                                 AmplitudeTracker.userPropABTestsRetention: retentionAbTests,
                                                 AmplitudeTracker.userPropABTestsChat: chatAbTests]
            dict.forEach({ (type, variables) in
                let identify = AMPIdentify()
                let trackingDataValue = NSArray(array: variables)
                identify.set(type, value: trackingDataValue)
                Amplitude.instance().identify(identify)
            })
        }.disposed(by: disposeBag)
    }
}
