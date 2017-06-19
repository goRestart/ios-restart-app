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
    static let defaultDistanceType = DistanceType.km
    static let defaultCoordinate = CLLocationCoordinate2DMake(38.897746, -77.037741)    // Washington
    static let productImageMaxSide: CGFloat = 1024
    static let productImageJPEGQuality: CGFloat = 0.9

    static let defaultManualLocationThreshold = 1000.0
    static let locationRetrievalTimeout: TimeInterval = 10    // seconds

    static let locationDistanceFilter: CLLocationDistance = 250
    static let locationDesiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters

    static let stickersRetrievalDebounceTime: TimeInterval = 3600 // Seconds (1hour)

    public static let defaultQuadKeyPrecision: Int = 13

    static let defaultShouldShowOnboarding = true

    static let viewedProductsThreshold = 5 // the view counts will be sent in batch when there are
                                            // at least 5 of them or when app goes to background
    static let websocketPingTimeInterval: TimeInterval = 180
    static let websocketBackgroundDisconnectTimeout: TimeInterval = 15
    static let openWebsocketInitialMinTimeInterval: TimeInterval = 1
    static let openWebsocketInitialMaxTimeInterval: TimeInterval = 3
    static let openWebsocketMaximumTimeInterval: TimeInterval = 7
    static let openWebsocketTimeIntervalMultiplier: Double = 1.4
    static let openWebsocketMaximumRetryAttempts: Int = 5

    static let networkBackgroundIdentifier = "com.letgo.ios.background"

    // Cars Vertical
    static let carsFirstYear: Int = 1900
    static let carsMakeEmptyValue = ""
    static let carsModelEmptyValue = ""
    static let carsYearEmptyValue = 0
    
}
