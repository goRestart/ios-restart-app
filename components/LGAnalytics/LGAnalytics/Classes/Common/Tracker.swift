//
//  Tracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
//

import LGCoreKit

public protocol Tracker {
    var application: AnalyticsApplication? { get set }
    func applicationDidFinishLaunching(launchOptions: [String: Any]?,
                                       apiKeys: AnalyticsAPIKeys)
    func applicationDidBecomeActive()
    func setInstallation(_ installation: Installation?)
    func setUser(_ user: MyUser?)
    func trackEvent(_ event: TrackerEvent)
    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?)
    func setNotificationsPermission(_ enabled: Bool)
    func setGPSPermission(_ enabled: Bool)
    func setMarketingNotifications(_ enabled: Bool)
    func setABTests(_ abTests: [AnalyticsABTestUserProperty])
}
