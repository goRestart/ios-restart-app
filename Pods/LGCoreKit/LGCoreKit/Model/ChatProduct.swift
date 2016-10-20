//
//  ChatProduct.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


public protocol ChatProduct: BaseModel, Priceable {
    var name: String? { get }
    var status: ProductStatus { get }
    var image: File? { get }
    var price: ProductPrice { get }
    var currency: Currency { get }
}
