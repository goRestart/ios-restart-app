//
//  LGUUID.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 18/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

protocol UUIDGenerator {
    var UUIDString: String { get }
}

class LGUUID: UUIDGenerator {
    var UUIDString: String {
        return NSUUID().uuidString.lowercased()
    }
}
