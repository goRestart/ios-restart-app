//
//  AdjustTracker.swift
//  LetGo
//
//  Created by Dídac on 14/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Adjust
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

    var eventToken: String {
        get {
            switch name {
            case .ProductOffer:
                return "tt24gv"
            case .ProductAskQuestion:
                return "mh4pby"
            case .ProductMarkAsSold:
                return "6p0zoj"
            case .ProductSellComplete:
                return "3as14u"
            case .SignupEmail:
                return "8vvoez"
            case .LoginEmail:
                return "f9nxpr"
            case .LoginFB:
                return "k8h0rz"
            case .ProductSellStart:
                return "xp5fgv"
            default:
                return ""
            }
        }
    }
}

public class AdjustTracker: Tracker {

    // MARK: - Tracker

    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        let adjustConfig = ADJConfig(appToken: EnvironmentProxy.sharedInstance.adjustAppToken, environment: EnvironmentProxy.sharedInstance.adjustEnvironment)
        adjustConfig.logLevel = ADJLogLevelInfo
        adjustConfig.eventBufferingEnabled = true
        Adjust.appDidLaunch(adjustConfig)
    }

    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        Adjust.appWillOpenUrl(url)
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
            Adjust.trackEvent(ADJEvent(eventToken: event.eventToken))
        }
    }

    public func updateCoordinates() {

    }

}