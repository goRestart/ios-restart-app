//
//  ApiProductsErrorCode.swift
//  LGCoreKit
//
//  Created by Juan on 10/07/17.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ApiProductsErrorCode {
    var code: Int { get }
    var message: String { get }
}
