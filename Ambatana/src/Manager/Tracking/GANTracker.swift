//
//  GANTracker.swift
//  LetGo
//
//  Created by Dídac on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .ProductSellComplete:
                return true
            case .ProductDetailVisit:
                return true
            case .ProductAskQuestion:
                return true
            case .ProductOffer:
                return true
            case .UserMessageSent:
                return true
            case .ProductMarkAsSold:
                return true
            case .ProductDeleteComplete:
                return true
            case .SignupEmail:
                return true
            case .LoginEmail:
                return true
            case .LoginFB:
                return true
            case .Logout:
                return true
            default:
                return false
            }
        }
    }
}

public class GANTracker: Tracker {

    // MARK: - Tracker

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {

//        var configureError:NSError?
//        GGLContext.sharedInstance().configureWithError(&configureError)
//        assert(configureError == nil, "Error configuring Google services: \(configureError)")
//
//        // Optional: configure GAI options.
//        let gai = GAI.sharedInstance()
//        gai.trackUncaughtExceptions = true  // report uncaught exceptions
//        gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
    }

    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        
    }

    public func applicationDidEnterBackground(application: UIApplication) {

    }

    public func applicationWillEnterForeground(application: UIApplication) {

    }

    public func applicationDidBecomeActive(application: UIApplication) {

    }

    public func setUser(user: MyUser?) {

    }

    public func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {

        }
    }

    public func updateCoordinates() {

    }
}