//
//  FacebookTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKCoreKit
import LGCoreKit

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .ProductSellStart, .ProductSellComplete, .FirstMessage, .ProductMarkAsSold, .ProductEditComplete:
                return true
            default:
                return false
            }
        }
    }
}

final class FacebookTracker: Tracker {
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
        FBSDKAppLinkUtility.fetchDeferredAppLink { (url, error) -> Void in
            if let actualURL = url {
                UIApplication.sharedApplication().openURL(actualURL)
            }
        }

    }

    func setInstallation(installation: Installation?) {
    }

    func setUser(user: MyUser?) {
    }
    
    func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {
            FBSDKAppEvents.logEvent(event.actualName, parameters: event.params?.stringKeyParams)
        }
    }

    func setLocation(location: LGLocation?) {}
    func setNotificationsPermission(enabled: Bool) {}
    func setGPSPermission(enabled: Bool) {}
    func setMarketingNotifications(enabled: Bool) {}
}
