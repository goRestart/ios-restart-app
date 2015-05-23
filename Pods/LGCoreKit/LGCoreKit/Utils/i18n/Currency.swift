//
//  Currency.swift
//  LGCoreKit
//
//  Created by AHL on 23/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public class Currency {
    public let code: String
    public let symbol: String
    init(code: String, symbol: String) {
        self.code = code
        self.symbol = symbol
    }
}
