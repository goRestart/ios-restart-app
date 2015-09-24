//
//  UrbanAirshipTracker.swift
//  LetGo
//
//  Created by Dídac on 25/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import UrbanAirship_iOS_SDK

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .LoginEmail:
                return true
            case .LoginFB:
                return true
            case .SignupEmail:
                return true
            case .ProductAskQuestion:
                return true
            case .ProductOffer:
                return true
            case .ProductSellComplete:
                return true
            case .ProductSellStart:
                return true
            case .ProductMarkAsSold:
                return true
            default:
                return false
            }
        }
    }
}


public class UrbanAirshipTracker: Tracker {

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
    
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
    
    }
    
    public func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
    
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
    
    }
    
    public func setUser(user: User?) {
        
    }
    
    public func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {
            let uaEvent = UACustomEvent(name: event.actualName)
            UAirship.shared()!.analytics.addEvent(uaEvent)
        }
    }
    
    public func updateCoordinates() {
        
    }

}
