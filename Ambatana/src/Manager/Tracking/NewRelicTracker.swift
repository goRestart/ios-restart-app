//
//  NewRelicTracker.swift
//  LetGo
//
//  Created by Eli Kohen on 09/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

final class NewRelicTracker: Tracker {

    // Constants
    // > Properties

    private static let sessionType = "session_type"
    private static let sessionSubjectId = "session_subject_id"

    private static let appSessionType = "app"
    private static let UserSessionType = "user"
    private static let guestSessionType = "guest"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
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
        var sessionType =  NewRelicTracker.guestSessionType
        var sessionId: String?
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

    func trackEvent(_ event: TrackerEvent) {
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {
    }

    func setNotificationsPermission(_ enabled: Bool) {
    }

    func setGPSPermission(_ enabled: Bool) {
    }

    func setMarketingNotifications(_ enabled: Bool) {
    }
}
