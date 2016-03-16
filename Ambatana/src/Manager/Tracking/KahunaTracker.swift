//
//  KahunaTracker.swift
//  LetGo
//
//  Created by Dídac on 22/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Kahuna

private struct KahunaParams {
    let name: String
    let specificParams: [String:String]?
    
    init(name: String, params: [String:String]?) {
        self.name = name
        self.specificParams = params
    }
    
    func createParams() -> [NSObject:AnyObject] {
        var userAttributes : [NSObject:AnyObject] = [:]

        if let actualParams = specificParams {
            for (key, value) in actualParams {
                userAttributes[key] = value
            }
        }
        
        return userAttributes
    }
}

private extension TrackerEvent {
    var kahunaEvents: KahunaParams? {
        get {
            switch name {
            case .ProductSellComplete:
                return KahunaParams(name: "product_sell_complete", params: nil)
            case .ProductSellStart:
                return KahunaParams(name: "product_sell_start", params: nil)
            default:
                return nil
            }
        }
    }
}

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .ProductSellStart, .ProductSellComplete:
                return true
            default:
                return false
            }
        }
    }
}

private extension TrackerEvent {
    var isSellComplete: Bool {
        get {
            switch name {
            case .ProductSellComplete:
                return true
            default:
                return false
            }
        }
    }
}

public class KahunaTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {

    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
    
    }
    
    public func applicationDidEnterBackground(application: UIApplication) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var userAttributes : Dictionary = Dictionary(dictionaryLiteral:("last_session_end_date", dateFormatter.stringFromDate(NSDate())), ("UUID", ""))
        
        if let userID = Core.myUserRepository.myUser?.objectId {
            userAttributes["UUID"] = userID
        }

        Kahuna.setUserAttributes(userAttributes)
        
        Kahuna.trackEvent("session_end")
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var userAttributes : Dictionary = Dictionary(dictionaryLiteral:("last_session_start_date", dateFormatter.stringFromDate(NSDate())), ("UUID", ""))

        if let userID = Core.myUserRepository.myUser?.objectId {
            userAttributes["UUID"] = userID
        }
        
        Kahuna.setUserAttributes(userAttributes)
        
        Kahuna.trackEvent("session_start")
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
    
    }

    public func setInstallation(installation: Installation) {
        var userAttributes = Kahuna.getUserAttributes() ?? [NSObject:AnyObject]()
        userAttributes["installation_id"] = installation.objectId ?? ""
        Kahuna.setUserAttributes(userAttributes)
    }

    public func setUser(user: MyUser?) {
        if let user = user {
            var userAttributes = Kahuna.getUserAttributes() ?? [NSObject:AnyObject]()
            let version =  NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
            let language = NSLocale.preferredLanguages()[0]

            userAttributes["public_username"] = user.name ?? ""
            userAttributes["language"] = language
            userAttributes["app_version"] = version
            
            if let latitude = user.location?.coordinate.latitude, let longitude = user.location?.coordinate.longitude {
                userAttributes["latitude"] = latitude
                userAttributes["longitude"] = longitude
                
                userAttributes["city"] = user.postalAddress.city ?? ""
                userAttributes["country_code"] = user.postalAddress.countryCode ?? ""
            }

            Kahuna.setUserAttributes(userAttributes)
            Kahuna.trackEvent("sign_in")
            
        } else {
            Kahuna.trackEvent("logout")
        }
    }
    
    public func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {
    
            var userAttributes : [NSObject:AnyObject] = [:]

            if let attributes = event.kahunaEvents?.createParams() {
                userAttributes = attributes
            }
            
            if event.isSellComplete {
                if let productId = event.params?.stringKeyParams["product-id"] as? String {
                    userAttributes["sell_complete_product_id"] = productId
                }

                if let categoryId = event.params?.stringKeyParams["category-id"] as? String {
                    userAttributes["sell_complete_category_id"] = categoryId
                }
            }
            
            Kahuna.setUserAttributes(userAttributes)
            Kahuna.trackEvent(event.name.rawValue)
        }

    }
    
    public func updateCoordinates() {
        
    }

    public func notificationsPermissionChanged() {

    }

    public func gpsPermissionChanged() {
        
    }
}
