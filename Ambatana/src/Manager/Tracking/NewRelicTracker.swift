//
//  NewRelicTracker.swift
//  LetGo
//
//  Created by Eli Kohen on 09/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGComponents
import LGCoreKit

final class NewRelicTracker: Tracker, LGComponents.Tracker {
    // TODO: ABIOS-3771 Remove : Tracker & LGComponents. when removing tracker in app
    // Constants
    // > Properties

    private static let sessionType = "session_type"
    private static let sessionSubjectId = "session_subject_id"

    private static let appSessionType = "app"
    private static let UserSessionType = "user"
    private static let guestSessionType = "guest"

    
    // MARK: - Tracker

    var application: AnalyticsApplication?

    func applicationDidFinishLaunching(launchOptions: [String: Any]?,
                                       apiKeys: AnalyticsAPIKeys) {
    }

    func application(openURL url: URL,
                     sourceApplication: String?,
                     annotation: Any?) {
    }


    func applicationDidEnterBackground() {
    }

    func applicationWillEnterForeground() {
    }

    func applicationDidBecomeActive() {
    }

    func setInstallation(_ installation: Installation?) {
        var sessionType = NewRelicTracker.guestSessionType
        var sessionId: String = ""
        if let sessionIdValue = installation?.objectId {
            sessionId = sessionIdValue
            sessionType = NewRelicTracker.appSessionType
        }
        NewRelic.setAttribute(NewRelicTracker.sessionType, value: sessionType)
        NewRelic.setAttribute(NewRelicTracker.sessionSubjectId, value: sessionId)
    }

    func setUser(_ user: MyUser?) {
        let sessionType =  NewRelicTracker.UserSessionType
        if let sessionId = user?.objectId {
            NewRelic.setAttribute(NewRelicTracker.sessionType, value: sessionType)
            NewRelic.setAttribute(NewRelicTracker.sessionSubjectId, value: sessionId)
        } else {
            setInstallation(Core.installationRepository.installation)
        }
    }

    func trackEvent(_ event: LGComponents.TrackerEvent) {   // TODO: ABIOS-3771 Remove LGComponents.
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {
    }

    func setNotificationsPermission(_ enabled: Bool) {
    }

    func setGPSPermission(_ enabled: Bool) {
    }

    func setMarketingNotifications(_ enabled: Bool) {
    }

    func setABTests(_ abTests: [AnalyticsABTestUserProperty]) {
    }


    // MARK: - Tracker (legacy) To be Removed

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?, featureFlags: FeatureFlaggeable) {
    }

    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func trackEvent(_ event: TrackerEvent) {
    }
}
