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

let kLetGoTrackingParameterNameUserEmail            = "user-email"
let kLetGoTrackingParameterNameCategoryName         = "category-email"
let kLetGoTrackingParameterNameProductName          = "product-name"
let kLetGoTrackingParameterNameNumber               = "number"
let kLetGoTrackingParameterNameEnabled              = "enabled"
let kLetGoTrackingParameterNameDescription          = "description"
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
    
    /** Shared instance */
    class var sharedInstance: TrackingManager {
        return _singletonInstance
    }
    
    override init() {
        super.init()
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
            kLetGoTrackingEventNameScreenPrivate: "SvhRCI6yqVsQ__6fyQM"
        ];
    }
    
    func trackEvent(eventName: String, eventParameter: String?, eventValue: String?) {
        // Track in Apps Flyer
        if eventParameter != nil && eventValue != nil {
            AppsFlyerTracker.sharedTracker().trackEvent(eventName, withValues: [eventParameter! : eventValue!])
        } else { AppsFlyerTracker.sharedTracker().trackEvent(eventName, withValue: "") }
        
        // Track in Amplitude
        if eventParameter != nil && eventValue != nil {
            Amplitude.instance().logEvent(eventName, withEventProperties: [eventParameter! : eventValue!])
        } else { Amplitude.instance().logEvent(eventName) }
        
        // Track in Facebook Events
        if eventParameter != nil && eventValue != nil {
            FBSDKAppEvents.logEvent(eventName, parameters: [eventParameter! : eventValue!])
        } else { FBSDKAppEvents.logEvent(eventName) }
        
        // Track in Google Conversion Analytics.
        ACTConversionReporter.reportWithConversionID(kLetGoGoogleConversionTrackingId, label: actLabelMap[eventName] ?? "", value: "0.00", isRepeatable: true)
    }
}
