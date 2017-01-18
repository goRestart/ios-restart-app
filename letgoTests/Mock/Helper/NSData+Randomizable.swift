//
//  Data+Randomizable.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 28/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation

extension Data {
    public static func random(kilobytes: Int) -> Data {
        let bytes = kilobytes * 1000
        let random = String.random(bytes)
        return random.data(using: .utf8)!    // utf-8 encodes 1 char as 1 byte
    }
}
