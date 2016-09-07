//
//  ErrorCode.swift
//  LGCoreKit
//
//  Created by Dídac on 30/08/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ApiErrorCode {
    var code: String { get }
    var title: String { get }
}
