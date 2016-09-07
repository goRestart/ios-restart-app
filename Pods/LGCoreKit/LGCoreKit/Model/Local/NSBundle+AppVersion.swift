//
//  NSBundle+AppVersion.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 26/05/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

extension NSBundle: AppVersion {
    var shortVersionString: String {
        return objectForInfoDictionaryKey("CFBundleShortVersionString") as? String ?? ""
    }
}
