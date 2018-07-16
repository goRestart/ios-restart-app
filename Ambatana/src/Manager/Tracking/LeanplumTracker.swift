//
//  LeanplumTracker.swift
//  LetGo
//
//  Created by Eli Kohen on 04/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import AppsFlyerLib


fileprivate extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .appRatingRate, .appRatingSuggest, .appRatingDontAsk,
                 .appInviteFriendComplete, .appInviteFriendDontAsk, .appInviteFriendCancel,
                 .userMessageSent,
                 .loginEmail, .loginFB, .loginGoogle, .signupEmail,
                 .searchComplete, .filterComplete,
                 .firstMessage, .listingOpenChat, .listingFavorite, .listingShareComplete,
                 .listingMarkAsSold, .listingDetailVisit,
                 .listingSellComplete, .listingSellStart,
                 .profileVisit, .surveyStart, .surveyCompleted, .onboardingInterestsComplete:
                return true
            default:
                return false
            }
        }
    }
}

final class LeanplumTracker: Tracker {

    // Constants
    // > User properties
    private static let userPropIdKey = "user-id"
    private static let userPropEmailKey = "user-email"
    private static let userPropLatitudeKey = "user-lat"
    private static let userPropLongitudeKey = "user-lon"
    private static let userPropCityKey = "user-city"
    private static let userPropCountryKey = "user-country-code"
    private static let userPropPublicUsernameKey = "user-public-username"
    private static let userPropReputationBadge = "reputation-badge"

    private static let userPropInstallationIdKey = "installation-id"
    private static let userPropLoggedIn = "logged-in"

    // enabled permissions
    private static let userPropPushEnabled = "push-enabled"
    private static let userPropGpsEnabled = "gps-enabled"

    private static let userPropMktNotificationsEnabled = "mkt-notifications-enabled"


    // MARK: - Tracker

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
                     featureFlags: FeatureFlaggeable) {
        if let deviceId = AppsFlyerTracker.shared().getAppsFlyerUID() {
            Leanplum.setDeviceId(deviceId)
        }
        Leanplum.onVariablesChanged { [weak featureFlags] in
            featureFlags?.variablesUpdated()
        }
        Leanplum.start()
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
        guard let installationId = installation?.objectId else { return }
        Leanplum.setUserAttributes([LeanplumTracker.userPropInstallationIdKey : installationId])
    }

    func setUser(_ user: MyUser?) {
        // https://ambatana.atlassian.net/browse/ABIOS-4446

        var userAttributes: [AnyHashable: Any] = [:]
        userAttributes[LeanplumTracker.userPropLoggedIn] = user != nil

        if let user = user {
            Leanplum.setUserId(user.objectId)
            userAttributes[LeanplumTracker.userPropIdKey] = user.objectId
            userAttributes[LeanplumTracker.userPropEmailKey] = user.email
            userAttributes[LeanplumTracker.userPropPublicUsernameKey] = user.name
            userAttributes[LeanplumTracker.userPropCityKey] = user.postalAddress.city
            userAttributes[LeanplumTracker.userPropCountryKey] = user.postalAddress.countryCode
            userAttributes[LeanplumTracker.userPropReputationBadge] = user.reputationBadge.rawValue
        }

        Leanplum.setUserAttributes(userAttributes)
    }

    func trackEvent(_ event: TrackerEvent) {
        guard event.shouldTrack else { return }
        Leanplum.track(event.actualName, withParameters: event.params?.leanplumStringKeyParams)
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {
        var userAttributes: [AnyHashable: Any] = [:]
        userAttributes[LeanplumTracker.userPropLatitudeKey] = location?.coordinate.latitude
        userAttributes[LeanplumTracker.userPropLongitudeKey] = location?.coordinate.longitude
        Leanplum.setUserAttributes(userAttributes)
    }

    func setNotificationsPermission(_ enabled: Bool) {
        Leanplum.setUserAttributes([LeanplumTracker.userPropPushEnabled : enabled ? "true" : "false"])
    }
    
    func setGPSPermission(_ enabled: Bool) {
        Leanplum.setUserAttributes([LeanplumTracker.userPropGpsEnabled : enabled ? "true" : "false"])
    }

    func setMarketingNotifications(_ enabled: Bool) {
        Leanplum.setUserAttributes([LeanplumTracker.userPropMktNotificationsEnabled : enabled])
    }
}

fileprivate extension EventParameters {
    var leanplumStringKeyParams: [String: Any] {
        var res = [String: Any]()
        for (paramName, value) in params {
            if let stringArray = value as? [Int] {
                res[paramName.rawValue] = stringArray.map{String($0)}.joined(separator: ",")
            } else {
                res[paramName.rawValue] = value
            }

        }
        return res
    }
}
