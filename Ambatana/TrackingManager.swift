//
//  TrackingManager.swift
//  LetGo
//
//  Created by Nacho on 17/4/15.
//  Copyright (c) 2015 LetGo. All rights reserved.
//

import UIKit

// tracking Events
let kLetGoTrackingEventNameLetGoInstall             = "letgo-install"
let kLetGoTrackingEventNameLoginFacebook            = "login-fb"
let kLetGoTrackingEventNameLoginEmail               = "login-email"
let kLetGoTrackingEventNameSignupEmail              = "signup-email"
let kLetGoTrackingEventNameLogout                   = "logout"
let kLetGoTrackingEventNameProductList              = "product-list"
let kLetGoTrackingEventNameProductDetailVisit       = "product-detail-visit"
let kLetGoTrackingEventNameProductDetailOffer       = "product-detail-offer"
let kLetGoTrackingEventNameProductDetailAskQuestion = "product-detail-ask-question"
let kLetGoTrackingEventNameProductDetailSold        = "product-detail-sold"
let kLetGoTrackingEventNameProductSellStart         = "product-sell-start"
let kLetGoTrackingEventNameProductSellAddPicture    = "product-sell-add-picture"
let kLetGoTrackingEventNameProductSellEditTitle     = "product-sell-edit-title"
let kLetGoTrackingEventNameProductSellEditPrice     = "product-sell-edit-price"
let kLetGoTrackingEventNameProductSellEditDesc      = "product-sell-edit-description"
let kLetGoTrackingEventNameProductSellEditCurrency  = "product-sell-edit-currency"
let kLetGoTrackingEventNameProductSellEditCategory  = "product-sell-edit-category"
let kLetGoTrackingEventNameProductSellEditShareFB   = "product-sell-edit-share-fb"
let kLetGoTrackingEventNameProductSellFormValidationFailed = "product-sell-form-validation-failed"
let kLetGoTrackingEventNameProductSellSharedFB      = "product-sell-shared-fb"
let kLetGoTrackingEventNameProductSellAbandon       = "product-sell-abandon"
let kLetGoTrackingEventNameProductSellComplete      = "product-sell-complete"
let kLetGoTrackingEventNameUserSentMessage          = "user-sent-message"
let kLetGoTrackingEventNameScreenPublic             = "screen-public"
let kLetGoTrackingEventNameScreenPrivate            = "screen-private"
let kLetGoTrackingEventDummyModifier                = "dummy-"
let kLetGoTrackingEventDummyUser                    = "usercontent"

let kLetGoTrackingParameterNameUserEmail            = "user-email"
let kLetGoTrackingParameterNameCategoryId           = "category-id"
let kLetGoTrackingParameterNameCategoryName         = "category-name"
let kLetGoTrackingParameterNameProductCity          = "product-city"
let kLetGoTrackingParameterNameProductCountry       = "product-country"
let kLetGoTrackingParameterNameProductZipCode       = "product-zipcode"
let kLetGoTrackingParameterNameProductName          = "product-name"
let kLetGoTrackingParameterNameUserCity             = "user-city"
let kLetGoTrackingParameterNameUserCountry          = "user-country"
let kLetGoTrackingParameterNameUserZipcode          = "user-zipcode"
let kLetGoTrackingParameterNameNumber               = "number"              // the number (index) of the picture
let kLetGoTrackingParameterNameEnabled              = "enabled"             // if a checkbox / switch is changed to enabled or disabled
let kLetGoTrackingParameterNameDescription          = "description"         // error description of the cause for form validation failure.
let kLetGoTrackingParameterNameItemType             = "item-type"           // real / dummy.
let kLetGoTrackingParameterNameScreenName           = "screen-name"

// IDs for tracking systems.
private let kLetGoAppsFlyerDevKey               = "5EKnCjmwmNKjE2e7gYBo6T"
private let kLetGoAppsFlyerAppleAppId           = "986339882"
private let kLetGoAmplitudeApiKey               = "1c32ba5ed444237608436bad4f310307"
private let kLetGoGoogleConversionTrackingId    = "958922623"

// private singleton instance
private let _singletonInstance = TrackingManager()

/**
 * The TrackingManager is in charge of tracking the user's activity. Currently, four tracking systems are enabled:
 * - AppsFlyer
 * - Amplitude
 * - Facebook events
 * - Google Conversion analytics.
 * The TrackingManager class must be accessed by means of the sharedInstance method, as it implements the Singleton design pattern.
 */
class TrackingManager: NSObject {
    // data
    // A map between an event name and the Google Conversion Tracker label parameter
    var actLabelMap: [String: String] = [:]
    // The queue for the tracking operations.
    var trackingDispatchQueue: dispatch_queue_t
    
    /** Shared instance */
    class var sharedInstance: TrackingManager {
        return _singletonInstance
    }
    
    override init() {
        // initialize tracking queue
        if iOSVersionAtLeast("8.0") {
            let queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, 0)
            trackingDispatchQueue = dispatch_queue_create("com.letgo.LetGoTrackingManagerQueue", queueAttributes)
        } else { trackingDispatchQueue = dispatch_queue_create("com.letgo.LetGoTrackingManagerQueue", 0) }
        
        // call supper
        super.init()
        
        // now initialize all tracking systems
        // Apps Flyer
        AppsFlyerTracker.sharedTracker().appsFlyerDevKey = kLetGoAppsFlyerDevKey
        AppsFlyerTracker.sharedTracker().appleAppID = kLetGoAppsFlyerAppleAppId
        AppsFlyerTracker.sharedTracker().customerUserID = ConfigurationManager.sharedInstance.userEmail
        // Amplitude
        Amplitude.initializeApiKey(kLetGoAmplitudeApiKey) // TODO: cambiar esto a Producción.
        Amplitude.instance().setUserId(ConfigurationManager.sharedInstance.userEmail)
        // FB: nothing needed here.
        // Google Conversion Analytics.
        ACTAutomatedUsageTracker.enableAutomatedUsageReportingWithConversionID(kLetGoGoogleConversionTrackingId)
        actLabelMap = [ // this maps between event names and ACT labels.
            kLetGoTrackingEventNameLetGoInstall: "p6XRCNq1qVsQ__6fyQM",
            kLetGoTrackingEventNameLoginFacebook: "cCIQCMywqVsQ__6fyQM",
            kLetGoTrackingEventNameLoginEmail: "v5HPCM_esVsQ__6fyQM",
            kLetGoTrackingEventNameSignupEmail: "Sv1cCM-zqVsQ__6fyQM",
            kLetGoTrackingEventNameLogout: "iLFXCJuwqVsQ__6fyQM",
            kLetGoTrackingEventNameProductList: "RIjACLawqVsQ__6fyQM",
            kLetGoTrackingEventNameProductDetailVisit: "UxPXCP7asVsQ__6fyQM",
            kLetGoTrackingEventNameProductDetailOffer: "JZUwCNLesVsQ__6fyQM",
            kLetGoTrackingEventNameProductDetailAskQuestion: "3zMYCM6wqVsQ__6fyQM",
            kLetGoTrackingEventNameProductDetailSold: "K2WnCPLasVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellStart: "XYo0CIW0qVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellAddPicture: "9X7JCKHdsVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellEditTitle: "OTQlCLqzqVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellEditPrice: "MXVqCLewqVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellEditDesc: "MABnCPrcsVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellEditCurrency: "1ZS1CKvesVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellEditCategory: "xkFRCIu0qVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellEditShareFB: "WZXtCPazqVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellFormValidationFailed: "8wYrCP3csVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellSharedFB: "U9yECImyqVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellAbandon: "-KmkCNjesVsQ__6fyQM",
            kLetGoTrackingEventNameProductSellComplete: "aNaiCIawqVsQ__6fyQM",
            kLetGoTrackingEventNameUserSentMessage: "6grCCKm0qVsQ__6fyQM",
            kLetGoTrackingEventNameScreenPublic: "Ito0CITbsVsQ__6fyQM",
            kLetGoTrackingEventNameScreenPrivate: "SvhRCI6yqVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameLoginFacebook: "zwVTCMunxVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameLoginEmail: "r-7WCLb1xFsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameSignupEmail: "IfaNCMj1xFsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameLogout: "A-yYCIPJzVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductList: "jdzqCPHIzVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductDetailVisit: "Sf4hCIvCzVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductDetailOffer: "p8aeCJzHzVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductDetailAskQuestion: "VCC-CJPHzVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductDetailSold: "CjBcCKymxVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellStart: "NonZCNOpxVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellAddPicture: "7hAGCISoxVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellEditTitle: "AImZCIz1xFsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellEditPrice: "kbuMCLmkxVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellEditDesc: "kyEqCMv4xFsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellEditCurrency: "ngBqCN3JzVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellEditCategory: "XGXWCL73xFsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellEditShareFB: "ijsRCKypxVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellFormValidationFailed: "H0HOCLynxVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellSharedFB: "7Z-ICPv4xFsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellAbandon: "KY1bCP3IzVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameProductSellComplete: "7IWHCM7JzVsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameUserSentMessage: "yyz4CJD5xFsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameScreenPublic: "tvXiCKX8xFsQ__6fyQM",
            kLetGoTrackingEventDummyModifier + kLetGoTrackingEventNameScreenPrivate: "LkyLCN7KzVsQ__6fyQM"
            
        ];
    }
    
    func trackEvent(eventName: String, var eventParameters: [String: AnyObject]?) {
        dispatch_async(trackingDispatchQueue) { () -> Void in
            // is this a dummy user? If so, we need to add the "dummy-" modifier to the event name.
            let isDummyUser = self.userIsDummyUser(PFUser.currentUser())
            // build final event name
            var eventFinalName = isDummyUser ? kLetGoTrackingEventDummyModifier + eventName : eventName
            
            // Track events with parameters.
            if eventParameters != nil && eventParameters?.count > 0 {
                // modify parameter item-type if dummy user (only if present).
                if let itemTypePresent = eventParameters![kLetGoTrackingParameterNameItemType] as? String {
                    eventParameters![kLetGoTrackingParameterNameItemType] = isDummyUser ? "dummy" : "real"
                }

                // Track in Apps Flyer
                AppsFlyerTracker.sharedTracker().trackEvent(eventFinalName, withValues: eventParameters!)
                // Track in Amplitude.
                Amplitude.instance().logEvent(eventFinalName, withEventProperties: eventParameters!)
                // Track in Facebook Events
                FBSDKAppEvents.logEvent(eventFinalName, parameters: eventParameters!)
            } else {
                // Track in Apps Flyer
                AppsFlyerTracker.sharedTracker().trackEvent(eventFinalName, withValue: "")
                // Track in Amplitude.
                Amplitude.instance().logEvent(eventFinalName)
                // Track in Facebook Events
                FBSDKAppEvents.logEvent(eventFinalName)
            }
            
            // in Amplitude, if user is dummy, we need to setUserProperties with a property of "UserType":"Dummy"
            if isDummyUser { Amplitude.instance().setUserProperties(["UserType":"Dummy"]) }

            // ACT likes to run in main queue.
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Track in Google Conversion Analytics.
                if let actEventName = self.actLabelMap[eventFinalName] {
                    ACTConversionReporter.reportWithConversionID(kLetGoGoogleConversionTrackingId, label: actEventName, value: "0.00", isRepeatable: true)
                }
            })
            
        }
    }
    
    func userIsDummyUser(whichUser: PFUser?) -> Bool {
        if whichUser == nil { return false }
        let retrievedUser = whichUser!.fetchIfNeeded()
        if let username = retrievedUser!["username"] as? String {
            if startsWith(username, kLetGoTrackingEventDummyUser) { return true } // dummy user
        }
        // if we have no username (not logged in?) we can't really tell this is a dummy user, so...
        return false
    }
}






