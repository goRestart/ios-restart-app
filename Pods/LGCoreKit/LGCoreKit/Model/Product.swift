//
//  PartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreGraphics
import UIKit

//Remove all setters and change by a factory method if required
public protocol Product: BaseModel {
    var name: String? { get }
    var descr: String? { get }
    var price: Float? { get } 
    var currency: Currency? { get }
    
    var location: LGLocationCoordinates2D { get }
    var postalAddress: PostalAddress { get }
    
    var languageCode: String? { get }
        
    var category: ProductCategory { get }
    var status: ProductStatus { get }
    
    var thumbnail: File? { get }
    var thumbnailSize: LGSize? { get }
    var images: [File] { get }          // Default value []
    
    var user: User { get }
    
    var updatedAt : NSDate? { get }
    var createdAt : NSDate? { get }
    
}

extension Product {
    public func formattedPrice() -> String {
        let actualCurrencyCode = currency?.code ?? LGCoreKitConstants.defaultCurrencyCode
        if let actualPrice = price {
            let formattedPrice = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(actualCurrencyCode, amount: actualPrice)
            return formattedPrice ?? "\(actualPrice)"
        }
        else {
            return ""
        }
    }
}