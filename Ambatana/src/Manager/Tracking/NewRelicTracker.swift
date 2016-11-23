//
//  NewRelicTracker.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
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
   
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        var sessionType: String = NewRelicTracker.guestSessionType
        var sessionId: String?
        
        if let userId = Core.myUserRepository.myUser?.objectId {
            sessionType =  NewRelicTracker.UserSessionType
            sessionId = userId
        } else if let installationId = Core.installationRepository.installation?.objectId {
            sessionType = NewRelicTracker.appSessionType
            sessionId = installationId
        }
        NewRelic.setAttribute(NewRelicTracker.sessionType, value: sessionType)
        NewRelic.setAttribute(NewRelicTracker.sessionSubjectId, value: sessionId)
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
    }
    
    func setUser(user: MyUser?) {
    }
    
    func trackEvent(event: TrackerEvent) {
    }
    
    func setLocation(location: LGLocation?) {
    }
    
    func setNotificationsPermission(enabled: Bool) {
    }
    
    func setGPSPermission(enabled: Bool) {
    }
    
    func setMarketingNotifications(enabled: Bool) {
    }
}
