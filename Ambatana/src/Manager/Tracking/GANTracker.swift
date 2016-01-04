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

    var ganCategory: String {
        get {
            switch name {
            case .ProductDetailVisit, .ProductAskQuestion, .ProductOffer:
                return "buyer"
            case .ProductSellComplete, .ProductMarkAsSold, .ProductDeleteComplete:
                return "seller"
            case .UserMessageSent, .SignupEmail, .LoginEmail, .LoginFB, .Logout:
                return "all"
            default:
                return "all"
            }
        }
    }
}

public class GANTracker: Tracker {

    // MARK: - Tracker

    public func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {

            var configureError:NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(configureError)")

            // Optional: configure GAI options.
            let gai = GAI.sharedInstance()
            gai.trackUncaughtExceptions = true  // report uncaught exceptions
            gai.logger.logLevel = GAILogLevel.Verbose  // remove before app release
    }

    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
        annotation: AnyObject?) {

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
            let tracker = GAI.sharedInstance().defaultTracker
            let builder = GAIDictionaryBuilder.createEventWithCategory(event.ganCategory, action:event.actualName,
                label: nil, value: nil)
            tracker.send(builder.build() as [NSObject:AnyObject])
        }
    }
    
    public func updateCoordinates() {
        
    }
}