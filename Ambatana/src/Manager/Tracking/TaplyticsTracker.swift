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
    private var lastUserInfo: MyUser?

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
        lastUserInfo = user
        guard readyToUpdateUser else { return }
        TaplyticsABTester.sharedInstance.setUserData(["user_id": user?.objectId ?? ""])
    }

    /*
     Sample of available keys when setting user:

     [Taplytics setUserAttributes: @{
     @"user_id": @"testUser",
     @"name": @"Test User",
     @"email": @"test@taplytics.com",
     @"gender": @"female",
     @"age": @25,
     @"avatarUrl": @"https://pbs.twimg.com/profile_images/497895869270618112/1zbNvWlD.png",
        @"customData": @{
            @"paidSubscriber": @YES,
            @"purchases": @3,
            @"totalRevenue": @42.42
        }
     }];
     */

    public func trackEvent(event: TrackerEvent) {
        Taplytics.logEvent(event.actualName)
        if event.name == .Logout {
            // must reset user, and make sure you do not set any new user attributes until you receive the callback.
            readyToUpdateUser = false
            Taplytics.resetUser { [weak self] in
                self?.readyToUpdateUser = true
                self?.setUser(self?.lastUserInfo)
            }
        }
    }

    public func updateCoordinates() {

    }

    public func notificationsPermissionChanged() {

    }

    public func gpsPermissionChanged() {
        
    }
}
