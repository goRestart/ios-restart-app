//
//  TaplyticsTracker.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Taplytics

public class TaplyticsTracker: Tracker {

    private var readyToUpdateUser = true

    // MARK: - Tracker

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        Taplytics.startTaplyticsAPIKey(EnvironmentProxy.sharedInstance.taplyticsApiKey)
    }

    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {

    }

    public func applicationDidEnterBackground(application: UIApplication) {

    }

    public func applicationWillEnterForeground(application: UIApplication) {

    }

    public func applicationDidBecomeActive(application: UIApplication) {

    }

    public func setInstallation(installation: Installation) {

    }

    public func setUser(user: MyUser?) {
        guard readyToUpdateUser else { return }

        if let actualUser = user {
            TaplyticsABTester.sharedInstance.setUserData(taplyticsUserData(actualUser))
        } else {
            // must reset user, and make sure you do not set any new user attributes until you receive the callback.
            readyToUpdateUser = false
            Taplytics.resetUser { [weak self] in
                self?.readyToUpdateUser = true
                if let myUser = Core.myUserRepository.myUser {
                    self?.setUser(myUser)
                }
            }
        }
    }

    public func trackEvent(event: TrackerEvent) {
        Taplytics.logEvent(event.actualName)
    }

    public func updateCoordinates() {

    }

    public func notificationsPermissionChanged() {

    }

    public func gpsPermissionChanged() {
        
    }


    // MARK: - private methods

    private func taplyticsUserData(user: MyUser) -> [String : AnyObject] {

        var userData: [String : AnyObject] = [:]
        userData["user_id"] = user.objectId ?? ""
        userData["email"] = user.email ?? ""
        return userData
    }
}
