//
//  NanigansTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

private struct NanigansParams {
    let eventType: String
    let name: String
    let extraParams: [NSObject : AnyObject]?
    
    init(eventType: String, name: String, extraParams: [NSObject : AnyObject]?) {
        self.eventType = eventType
        self.name = name
        self.extraParams = extraParams
    }
}

private extension TrackerEvent {
    var nanigansParams: NanigansParams? {
        get {
            switch name {
            case .LoginEmail, .LoginFB, .SignupEmail:
                return NanigansParams(eventType: "install", name: "reg", extraParams: nil)
            case .ProductAskQuestion:
                return NanigansParams(eventType: "user", name: actualName, extraParams: nil)
            case .ProductOffer:
                return NanigansParams(eventType: "user", name: actualName, extraParams: nil)
            case .ProductSellComplete:
                return NanigansParams(eventType: "user", name: actualName, extraParams: nil)
            case .ProductSellStart:
                return NanigansParams(eventType: "user", name: actualName, extraParams: nil)
            default:
                return nil
            }
        }
    }
}

public class NanigansTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        NANTracking.setNanigansAppId(EnvironmentProxy.sharedInstance.nanigansAppId, fbAppId: EnvironmentProxy.sharedInstance.nanigansAppId)
        NANTracking.trackAppLaunch(nil)
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        NANTracking.trackAppLaunch(url)
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        NANTracking.trackAppLaunch(nil)
    }
    
    public func setUser(user: User) {
        NANTracking.setUserId(user.email)
    }
    
    public func trackEvent(event: TrackerEvent) {
        if let nanigansParams = event.nanigansParams {
            NANTracking.trackNanigansEvent(nanigansParams.eventType, name: nanigansParams.name, extraParams: nanigansParams.extraParams)
        }
    }
}