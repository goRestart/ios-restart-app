//
//  AppVersion.swift
//  LetGo
//
//  Created by Albert Hernández López on 25/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum AppVersion: String, Comparable {
    case Current = "1.4.0"
    
    public static var currentVersion: AppVersion? {
        if let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
            return AppVersion(rawValue: buildNumber)
        }
        return nil
    }
}