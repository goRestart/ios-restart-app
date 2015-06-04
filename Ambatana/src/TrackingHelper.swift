//
//  TrackingHelper.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Amplitude_iOS
//import AppsFlyer_SDK
import FBSDKCoreKit
import LGCoreKit
import Parse

// Enums

enum TrackingEvent: String {
    case LoginVisit                        = "login-screen"
    case LoginFB                           = "login-fb"
    case LoginEmail                        = "login-email"
    case SignupEmail                       = "signup-email"
    case Logout                            = "logout"
    case ProductList                       = "product-list"
    case ProductDetailVisit                = "product-detail-visit"
    case ProductOffer                      = "product-detail-offer"
    case ProductAskQuestion                = "product-detail-ask-question"
    case ProductMarkAsSold                 = "product-detail-sold"
    case ProductSellStart                  = "product-sell-start"
    case ProductSellAddPicture             = "product-sell-add-picture"
    case ProductSellEditTitle              = "product-sell-edit-title"
    case ProductSellEditPrice              = "product-sell-edit-price"
    case ProductSellEditDescription        = "product-sell-edit-description"
    case ProductSellEditCategory           = "product-sell-edit-category"
    case ProductSellEditShareFB            = "product-sell-edit-share-fb"
    case ProductSellFormValidationFailed   = "product-sell-form-validation-failed"
    case ProductSellSharedFB               = "product-sell-shared-fb"
    case ProductSellAbandon                = "product-sell-abandon"
    case ProductSellComplete               = "product-sell-complete"
    case UserMessageSent                   = "user-sent-message"
    
    var shouldTrackOnAppsFlyer: Bool {
        if self == .ProductList {   // not tracked in AppsFlyer as we're exceeding their quota
            return false
        }
        return true
    }
    
    var googleConversionParams: GoogleConversionParams? {
        switch (self) {
        case ProductSellComplete:
            return GoogleConversionParams(label: "aNaiCIawqVsQ__6fyQM", value: "0.00", isRepeatable: true)
        default:
            return nil
        }
    }
}

struct GoogleConversionParams {
    let label: String
    let value: String
    let isRepeatable: Bool
    init(label: String, value: String, isRepeatable: Bool) {
        self.label = label
        self.value = value
        self.isRepeatable = isRepeatable
    }
}

enum TrackingParameter: String {
    case UserEmail            = "user-email"
    case CategoryId           = "category-id"       // 0 if there's no category
    case CategoryName         = "category-name"     // "none" if there's no category
    case ProductCity          = "product-city"
    case ProductCountry       = "product-country"
    case ProductZipCode       = "product-zipcode"
    case ProductName          = "product-name"
    case UserCity             = "user-city"
    case UserCountry          = "user-country"
    case UserZipCode          = "user-zipcode"
    case Number               = "number"            // the number/index of the picture
    case Enabled              = "enabled"           // true/false. if a checkbox / switch is changed to enabled or disabled
    case Description          = "description"       // error description: why form validation failure.
    case ItemType             = "item-type"         // real / dummy.
}

class TrackingHelper {
    
    // Constants
    private static let googleConversionInstallParams = GoogleConversionParams(label: "p6XRCNq1qVsQ__6fyQM", value: "0.00", isRepeatable: false)
    
    // > Prefixes
    private static let eventNameDummyPrefix   = "dummy-"
    
    // > User properties
    private static let userPropTypeKey = "UserType"
    private static let userPropTypeValueDummy = "Dummy"
    
    // > Item type
    private static let eventValueItemTypeReal = "real"
    private static let eventValueItemTypeDummy = "dummy"
    
    // MARK: - Internal methods
    
    static func appDidFinishLaunching() {
        // Amplitude
        Amplitude.initializeApiKey(EnvironmentProxy.sharedInstance.amplitudeAPIKey)
        
        // AppsFlyer
        AppsFlyerTracker.sharedTracker().appsFlyerDevKey = EnvironmentProxy.sharedInstance.appsFlyerAPIKey
        AppsFlyerTracker.sharedTracker().appleAppID = EnvironmentProxy.sharedInstance.appleAppId
        
        // Google conversion tracking
        ACTAutomatedUsageTracker.enableAutomatedUsageReportingWithConversionID(EnvironmentProxy.sharedInstance.googleConversionTrackingId)

        // > Track the install
        let installParams = TrackingHelper.googleConversionInstallParams
        ACTConversionReporter.reportWithConversionID(EnvironmentProxy.sharedInstance.googleConversionTrackingId, label: installParams.label, value: installParams.value, isRepeatable: installParams.isRepeatable)
    }
    
    static func appDidBecomeActive() {
        // AppsFlyer
        AppsFlyerTracker.sharedTracker().trackAppLaunch()
        
        // Facebook
        FBSDKAppEvents.activateApp()
    }
    
    static func setUserId(userId: String) {
        // Amplitude
        Amplitude.instance().setUserId(userId)
        if isDummyUserName(userId) {
            Amplitude.instance().setUserProperties([TrackingHelper.userPropTypeKey: TrackingHelper.userPropTypeValueDummy], replace: true)
        }
        // AppsFlyer
        AppsFlyerTracker.sharedTracker().customerUserID = userId
    }
    
    static func trackEvent(eventType: TrackingEvent, parameters: [TrackingParameter: AnyObject]?) {
        // The event name should be prefixed with dummy if needed
        let eventName: String
        let isDummyUser = TrackingHelper.isDummyUser(PFUser.currentUser())
        if let actualIsDummyUser = isDummyUser {
            if actualIsDummyUser {
                eventName = eventNameDummyPrefix + eventType.rawValue
            }
            else {
                eventName = eventType.rawValue
            }
        }
        else {
            eventName = eventType.rawValue
        }
        
        // If there are params, transform to [String: AnyObject]
        var params: [String: AnyObject]?
        if let actualParameters = parameters {
            params = [String: AnyObject]()
            for (param, value) in actualParameters {
                params![param.rawValue] = value
            }
        }
        
        // Amplitude, AppsFlyer & Facebook
        if let actualParams = params {
            Amplitude.instance().logEvent(eventName, withEventProperties: actualParams)
            if eventType.shouldTrackOnAppsFlyer {
                AppsFlyerTracker.sharedTracker().trackEvent(eventName, withValues: actualParams)
            }
            FBSDKAppEvents.logEvent(eventName, parameters: actualParams)
        }
        else {
            Amplitude.instance().logEvent(eventName)
            if eventType.shouldTrackOnAppsFlyer {
                AppsFlyerTracker.sharedTracker().trackEvent(eventName, withValue: nil)
            }
            FBSDKAppEvents.logEvent(eventName)
        }
        
        // Google conversion tracking
        if let gctParams = eventType.googleConversionParams {
            ACTConversionReporter.reportWithConversionID(EnvironmentProxy.sharedInstance.googleConversionTrackingId, label: gctParams.label, value: gctParams.value, isRepeatable: gctParams.isRepeatable)
        }
    }
    
    // MARK: > Helper
    
    static func productTypeParamValue(isDummy: Bool) -> String {
        return isDummy ? eventValueItemTypeDummy : eventValueItemTypeReal
    }
    
    static func isDummyUser(user: PFUser?) -> Bool? {
        if let actualUser = user, let username = actualUser.username {
            return TrackingHelper.isDummyUserName(username)
        }
        return nil
    }
    
    static func isDummyUser(user: User?) -> Bool? {
        // FIXME:
//        if let actualUser = user, let username = actualUser.username {
//            return TrackingHelper.isDummyUserName(username)
//        }
        return false
    }
    
    private static func isDummyUserName(username: String) -> Bool {
        return startsWith(username, "usercontent")
    }
}