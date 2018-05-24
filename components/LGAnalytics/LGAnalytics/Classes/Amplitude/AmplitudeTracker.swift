//
//  AmplitudeTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
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
    
    private static let userPropMktPushNotificationKey = "marketing-push-notification"
    private static let userPropMktPushNotificationValueOn = "on"
    private static let userPropMktPushNotificationValueOff = "off"

    // > Prefix
    private static let dummyEmailPrefix = "usercontent"

    // Login required tracking
    private var amplitude: Amplitude {
        return Amplitude.instance()
    }
    private var loggedIn = false
    private var pendingLoginEvent: TrackerEvent?

    private let disposeBag = DisposeBag()

    
    // MARK: - Tracker

    weak var application: AnalyticsApplication?

    func applicationDidFinishLaunching(launchOptions: [String: Any]?,
                                       apiKeys: AnalyticsAPIKeys) {
        amplitude.trackingSessionEvents = false
        amplitude.initializeApiKey(apiKeys.amplitudeAPIKey)
    }
    
    func applicationDidBecomeActive() {
    }

    func setInstallation(_ installation: Installation?) {
        let identify = AMPIdentify()
        let installationValue = NSString(string: installation?.objectId ?? "")
        identify.set(AmplitudeTracker.userPropInstallationIdKey, value: installationValue)
        amplitude.identify(identify)
    }

    func setUser(_ user: MyUser?) {
        amplitude.setUserId(user?.amplitudeUserId)

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
        amplitude.identify(identify)

        loggedIn = user != nil
        if let pendingLoginEvent = pendingLoginEvent {
            trackEvent(pendingLoginEvent)
        }
    }
    
    func trackEvent(_ event: TrackerEvent) {
        switch event.name {
        case .loginEmail, .loginFB, .loginGoogle, .signupEmail:
            if loggedIn {
                amplitude.logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)
                pendingLoginEvent = nil
            } else {
                pendingLoginEvent = event
            }
        default:
            amplitude.logEvent(event.actualName, withEventProperties: event.params?.stringKeyParams)
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
        amplitude.identify(identify)
    }

    func setNotificationsPermission(_ enabled: Bool) {
        let identify = AMPIdentify()
        let enabledValue = NSString(string: enabled ? "true" : "false")
        identify.set(AmplitudeTracker.userPropPushEnabled, value: enabledValue)
        amplitude.identify(identify)
    }

    func setGPSPermission(_ enabled: Bool) {
        let identify = AMPIdentify()
        let enabledValue = NSString(string: enabled ? "true" : "false")
        identify.set(AmplitudeTracker.userPropGpsEnabled, value: enabledValue)
        amplitude.identify(identify)
    }

    func setMarketingNotifications(_ enabled: Bool) {
        let identify = AMPIdentify()
        let value = enabled ? AmplitudeTracker.userPropMktPushNotificationValueOn :
            AmplitudeTracker.userPropMktPushNotificationValueOff
        let valueNotifications = NSString(string: value)
        identify.set(AmplitudeTracker.userPropMktPushNotificationKey, value: valueNotifications)
        amplitude.identify(identify)
    }

    func setABTests(_ abTests: [AnalyticsABTestUserProperty]) {
        AmplitudeTracker.makeAmplitudeGroupedABTestDictionary(abTests: abTests).forEach { (groupId, ids) in
            let identify = AMPIdentify()
            identify.set(groupId, value: NSArray(array: ids))
            amplitude.identify(identify)
        }
    }


    // MARK: - Private

    private static func makeAmplitudeGroupedABTestDictionary(abTests: [AnalyticsABTestUserProperty]) -> [String: [String]] {
        var dictionary = [String: [String]]()
        abTests.forEach { abTest in
            let key = abTest.groupIdentifier.rawValue
            var identifiers = dictionary[key] ?? []
            identifiers.append(abTest.identifier)
            dictionary[key] = identifiers
        }
        return dictionary
    }
}
