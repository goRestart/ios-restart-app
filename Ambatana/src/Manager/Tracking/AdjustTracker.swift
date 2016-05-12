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
            case .ProductOffer, .ProductAskQuestion, .ProductMarkAsSold, .ProductSellComplete, .ProductSellComplete24h:
                return true
            default:
                return false
            }
        }
    }

    var eventToken: String? {
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
            case .ProductSellComplete24h:
                return "c7ys45"
            default:
                return nil
            }
        }
    }
}

final class AdjustTracker: Tracker {

    // MARK: - Tracker

    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
            let adjustConfig = ADJConfig(appToken: EnvironmentProxy.sharedInstance.adjustAppToken,
                environment: EnvironmentProxy.sharedInstance.adjustEnvironment)
            adjustConfig.logLevel = ADJLogLevelInfo
            adjustConfig.eventBufferingEnabled = true
            Adjust.appDidLaunch(adjustConfig)
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
        annotation: AnyObject?) {
            Adjust.appWillOpenUrl(url)
    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func setInstallation(installation: Installation?) {

    }

    func setUser(user: MyUser?) {

    }

    func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {
            guard let eventToken = event.eventToken else { return }

            let adjustEvent = ADJEvent(eventToken: eventToken)
            if let installationId = Core.installationRepository.installation?.objectId {
                adjustEvent.addCallbackParameter("installation_id", value: installationId)
            }
            Adjust.trackEvent(adjustEvent)

        }
    }

    func setLocation(location: LGLocation?) {}
    func setNotificationsPermission(enabled: Bool) {}
    func setGPSPermission(enabled: Bool) {}
}
