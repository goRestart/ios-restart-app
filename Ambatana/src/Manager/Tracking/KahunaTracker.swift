//
//  KahunaTracker.swift
//  LetGo
//
//  Created by Dídac on 22/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

//private extension TrackerEvent {
//    var shouldTrack: Bool {
//        get {
//            switch name {
//            case .ProductOffer:
//                return true
//            case .ProductAskQuestion:
//                return true
//            case .ProductMarkAsSold:
//                return true
//            case .ProductSellComplete:
//                return true
//            default:
//                return false
//            }
//        }
//    }
//}

public class KahunaTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {

    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
    
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
    
    }
    
    public func setUser(user: User?) {
    
    }
    
    public func trackEvent(event: TrackerEvent) {
//        if event.shouldTrack {
//    
//        }
    }
    
    public func updateCoordinates() {
        
    }
    
}