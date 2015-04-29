//
//  SessionToken.swift
//  LGCoreKit
//
//  Created by AHL on 29/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import UIKit

public protocol SessionToken {
    var accessToken: String { get set }
    var expirationDate: NSDate { get set }
    func isExpired() -> Bool
}
