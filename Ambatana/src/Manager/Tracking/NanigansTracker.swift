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
    
    init(eventType: String, name: String) {
        self.eventType = eventType
        self.name = name
    }
}

private extension TrackerEvent {
    var nanigansParams: NanigansParams? {
        get {
            switch name {
            case .LoginEmail, .LoginFB, .SignupEmail:
                return NanigansParams(eventType: "install", name: "reg")
            case .ProductAskQuestion:
                return NanigansParams(eventType: "user", name: actualName)
            case .ProductOffer:
                return NanigansParams(eventType: "user", name: actualName)
            case .ProductSellComplete:
                return NanigansParams(eventType: "user", name: actualName)
            case .ProductSellStart:
                return NanigansParams(eventType: "user", name: actualName)
            default:
                return nil
            }
        }
    }
}

final class NanigansTracker: Tracker {
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        NANTracking.setNanigansAppId(EnvironmentProxy.sharedInstance.nanigansAppId, fbAppId: EnvironmentProxy.sharedInstance.facebookAppId)
        
        if EnvironmentProxy.sharedInstance.environment is DevelopmentEnvironment {
            NANTracking.setDebugMode(true)
        }
        NANTracking.trackAppLaunch(nil)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        NANTracking.trackAppLaunch(url)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        NANTracking.trackAppLaunch(nil)
    }

    func setInstallation(installation: Installation?) {
    }

    func setUser(user: MyUser?) {
        let userId = user?.objectId ?? ""
        NANTracking.setUserId(userId)
    }
    
    func trackEvent(event: TrackerEvent) {
        if let nanigansParams = event.nanigansParams {

            var nanStringKeyParams : [String: AnyObject] = [:]
            
            if let params = event.params?.stringKeyParams {
                for (name, value) in params {
                    nanStringKeyParams[name] = value
                }
                if let email = Core.myUserRepository.myUser?.email {
                    nanStringKeyParams["ut1"] = stringSha256(email)
                }
            }

            NANTracking.trackNanigansEvent(nanigansParams.eventType, name: nanigansParams.name, extraParams: nanStringKeyParams)
        }
    }

    func setLocation(location: LGLocation?) {}
    func setNotificationsPermission(enabled: Bool) {}
    func setGPSPermission(enabled: Bool) {}
    
    private func stringSha256(email: String) -> NSString? {
        
        let cleanEmail = email.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).lowercaseString
        
        if let data = cleanEmail.dataUsingEncoding(NSUTF8StringEncoding) {

            var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
            CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
            let resstr = NSMutableString()
            for byte in hash {
                resstr.appendFormat("%02hhx", byte)
            }
            return resstr
        }
        return ""
    }
}
