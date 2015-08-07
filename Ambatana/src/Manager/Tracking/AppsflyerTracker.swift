//
//  AppsFlyerTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

//import AppsFlyer_SDK
import LGCoreKit

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .ProductOffer:
                return true
            case .ProductAskQuestion:
                return true
            case .ProductMarkAsSold:
                return true
            case .ProductSellComplete:
                return true
            default:
                return false
            }
        }
    }
}

public class AppsflyerTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        AppsFlyerTracker.sharedTracker().appsFlyerDevKey = EnvironmentProxy.sharedInstance.appsFlyerAPIKey
        AppsFlyerTracker.sharedTracker().appleAppID = EnvironmentProxy.sharedInstance.appleAppId
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        AppsFlyerTracker.sharedTracker().trackAppLaunch()
    }
    
    public func setUser(user: User) {
        AppsFlyerTracker.sharedTracker().customerUserID = user.email
    }
    
    public func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {
            AppsFlyerTracker.sharedTracker().trackEvent(event.actualName, withValues: event.params?.stringKeyParams)
        }
    }
}
