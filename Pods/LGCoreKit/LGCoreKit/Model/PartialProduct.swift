//
//  PartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreGraphics
import UIKit

public protocol PartialProduct {
    var objectId: String? { get set }
    var createdAt: NSDate? { get set }
    
    var name: String { get set }
    var price: Float? { get set }
    var currencyCode: String? { get set }
    var distance: Float? { get set }
    var distanceType: DistanceType? { get set }
    
    var categoryId: Int? { get set }
    var status: ProductStatus? { get set }
    
    var thumbnailURL: NSURL? { get set }
    var thumbnailSize: LGSize? { get set }
}