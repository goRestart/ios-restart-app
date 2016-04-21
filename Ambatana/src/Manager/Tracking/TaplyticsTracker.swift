//
//  TaplyticsTracker.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Taplytics

final class TaplyticsTracker: Tracker {

    private var readyToUpdateUser = true

    // MARK: - Tracker

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        Taplytics.startTaplyticsAPIKey(EnvironmentProxy.sharedInstance.taplyticsApiKey, options: ["delayLoad": 0])
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

    func trackEvent(event: TrackerEvent) {
        Taplytics.logEvent(event.actualName)
    }

    func setLocation(location: LGLocation?) {}
    func setNotificationsPermission(enabled: Bool) {}
    func setGPSPermission(enabled: Bool) {}


    // MARK: - private methods

    private func taplyticsUserData(user: MyUser) -> [String : AnyObject] {

        var userData: [String : AnyObject] = [:]
        userData["user_id"] = user.objectId ?? ""
        userData["email"] = user.email ?? ""
        return userData
    }
}
