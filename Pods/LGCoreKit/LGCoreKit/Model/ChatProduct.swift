//
//  ChatProduct.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


public protocol ChatProduct: BaseModel {
    var name: String { get }
    var status: String { get }
    var image: File? { get }
    var price: Double { get }
    var currency: Currency? { get }
}
