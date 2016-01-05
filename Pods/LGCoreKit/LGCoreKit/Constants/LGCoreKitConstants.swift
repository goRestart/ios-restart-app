//
//  LGCoreKitConstants.swift
//  LGCoreKit
//
//  Created by AHL on 24/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public struct LGCoreKitConstants {
    static let usdCurrency = Currency(code: "USD", symbol: "$")
    static let eurCurrency = Currency(code: "EUR", symbol: "€")

    static let defaultCurrency = LGCoreKitConstants.usdCurrency
    static let defaultCurrencyCode = "USD"
    static let defaultDistanceType = DistanceType.Km
    static let defaultCoordinate = CLLocationCoordinate2DMake(38.897746, -77.037741)    // Washington
    static let productImageMaxSide: CGFloat = 1024
    static let productImageJPEGQuality: CGFloat = 0.9
    
    static let httpHeaderUserToken = "X-Letgo-Parse-User-Token"
    
    static let defaultManualLocationThreshold = 1000.0
    static let locationRetrievalTimeout: NSTimeInterval = 10    // seconds
    
    static let locationDistanceFilter: CLLocationDistance = 250
    static let locationDesiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters
    
    public static let defaultQuadKeyPrecision: Int = 15
    
    static let defaultConfigTimeOut: Double = 3    // seconds
    
    static let defaultShouldShowOnboarding = true
}
