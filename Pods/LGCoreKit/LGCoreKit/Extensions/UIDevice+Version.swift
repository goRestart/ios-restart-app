//
//  UIDevice+Version.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

public enum OSVersion: String {
    case iOS8_0_0 = "8.0.0"
}

extension UIDevice {
    public static func isOSAtLeast(osVersion: OSVersion) -> Bool {
        switch UIDevice.currentDevice().systemVersion.compare(osVersion.rawValue, options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            return true
        case .OrderedAscending:
            return false
        }
    }
}
