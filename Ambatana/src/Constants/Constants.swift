//
//  Constants.swift
//  LetGo
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

struct Constants {
    // Currency
    static let defaultCurrencyCode = "USD"
    
    // Input validation
    static let fullNameMinLength = 2
    static let passwordMinLength = 4
    static let passwordMaxLength = 20
    static let productDescriptionMaxLength = 1500

    // Map
    static let accurateRegionRadius = 1000.0    // meters
    static let nonAccurateRegionRadius = 5000.0 // meters
    
    // URLs
    static let appStoreURL = "http://itunes.apple.com/app/id%@?mt=8"
    static let websiteURL = "http://www.letgo.com"
    static let helpURL = "http://%@.letgo.com/%@/help_app"
    static let termsAndConditionsURL = "http://%@.letgo.com/%@/terms_app"
    static let privacyURL = "http://%@.letgo.com/%@/privacy_app"
    static let productURL = "\(Constants.websiteURL)/product/%@"
    static let whatsAppShareURL = "whatsapp://send?text=%@"
    
    // Tab bar
    static let tabBarSellFloatingButtonHeight: CGFloat = 70
    
    // Product List
    static let productListMaxDistanceLabel = 20
    static let productListMaxMinsLabel = 60.0
    static let productListMaxHoursLabel = 24.0
    static let productListMaxDaysLabel = 30.0
    static let productListMaxMonthsLabel = 3.0
    static let productListFooterHeight: CGFloat = 70
    static let productListFixedInsets: CGFloat = 5
    static let productListNewLabelThreshold: NSTimeInterval = 60 * 60 * 24 // 1 day
    
    // Categories
    static let categoriesCellFactor: CGFloat = 150.0 / 160.0
    
    // Filters
    static var distanceFilterDefault = 0
    static let distanceFilterOptions = [0, 1, 10, 20, 30, 100]
    
    // App sharing
    static let facebookAppLinkURL = "https://fb.me/900185926729336"
    static let facebookAppInvitePreviewImageURL = "http://cdn.letgo.com/static/app-invites-facebook.jpg"

    // Pre Permissions
    static let itemIndexPushPermissionsTrigger = 10
    static let pushPermissionRepeatTime = (60 * 60 * 24) // 1 day

    // Product posting
    static let maxPriceIntegerCharacters = 9
    static let maxPriceFractionalCharacters = 2

    // Messages retrieving
    // TODO: ensure the num of results with PO and put correct value back
    static let numMessagesPerPage = 20 // 100 -> described in jira task ABIOS-882 - left to 20 for testing purposes

}
