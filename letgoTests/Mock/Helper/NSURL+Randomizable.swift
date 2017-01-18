//
//  URL+Randomizable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/01/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

extension URL {
    public static func random() -> URL {
        return URL(string: String.randomURL())!
    }
}
