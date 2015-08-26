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
    static let productDescriptionMaxLength = 256

    // Map
    static let accurateRegionRadius = 1000.0    // meters
    static let nonAccurateRegionRadius = 5000.0 // meters
    
    // URLs
    static let appStoreURL = "http://itunes.apple.com/app/id%@?mt=8"
    static let websiteURL = "http://www.letgo.com"
    static let productURL = "\(Constants.websiteURL)/product/%@"
    static let whatsAppShareURL = "whatsapp://send?text=%@"
    
}
