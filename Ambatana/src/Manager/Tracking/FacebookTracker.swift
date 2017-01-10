//
//  FacebookTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKCoreKit
import LGCoreKit

fileprivate extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .ProductSellStart, .productSellComplete, .FirstMessage, .ProductMarkAsSold, .ProductEditComplete:
                return true
            default:
                return false
            }
        }
    }
}

final class FacebookTracker: Tracker {
    
    // MARK: - Tracker
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
        
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
        FBSDKAppLinkUtility.fetchDeferredAppLink { (url, error) -> Void in
            if let actualURL = url {
                UIApplication.shared.openURL(actualURL)
            }
        }

    }

    func setInstallation(_ installation: Installation?) {
    }

    func setUser(_ user: MyUser?) {
    }
    
    func trackEvent(_ event: TrackerEvent) {
        if event.shouldTrack {
            FBSDKAppEvents.logEvent(event.actualName, parameters: event.params?.stringKeyParams)
        }
    }

    func setLocation(_ location: LGLocation?) {}
    func setNotificationsPermission(_ enabled: Bool) {}
    func setGPSPermission(_ enabled: Bool) {}
    func setMarketingNotifications(_ enabled: Bool) {}
}
