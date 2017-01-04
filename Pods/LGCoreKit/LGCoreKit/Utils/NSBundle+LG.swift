//
//  NSBundle+LG.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

extension Bundle {
    internal static func LGCoreKitBundle() -> Bundle {
        let frameworkBundle = Bundle(for: LGCoreKit.self)
        let lgCoreKitBundleURL = frameworkBundle.url(forResource: "LGCoreKitBundle", withExtension: "bundle")!
        return Bundle(url: lgCoreKitBundleURL)!
    }
}
