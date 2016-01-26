//
//  NSBundle+LG.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

extension NSBundle {
    internal static func LGCoreKitBundle() -> NSBundle {
        let frameworkBundle = NSBundle(forClass: LGCoreKit.self)
        let lgCoreKitBundleURL = frameworkBundle.URLForResource("LGCoreKitBundle", withExtension: "bundle")!
        return NSBundle(URL: lgCoreKitBundleURL)!
    }
}
