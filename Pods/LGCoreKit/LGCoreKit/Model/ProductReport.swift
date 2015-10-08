//
//  ProductReport.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public protocol ProductReport: BaseModel {
    var product: Product? { get set }
    var userReporter: User? { get set }
    var userReported: User? { get set }
}