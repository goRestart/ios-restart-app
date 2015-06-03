//
//  PartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreGraphics
import UIKit

public protocol Product {
    var objectId: String? { get set }
    var createdAt: NSDate? { get set }
    var updatedAt: NSDate? { get set }
    
    var name: String? { get set }
    var description: String? { get set }
    var price: Float? { get set }
    var currencyCode: String? { get set }
    
    var location: LGLocationCoordinates2D? { get set }
    var distance: Float? { get set }
    var distanceType: DistanceType? { get set }
    
    var postalAddress: PostalAddress? { get set }
    
    var languageCode: String? { get set }
        
    var categoryId: Int? { get set }
    var status: ProductStatus? { get set }
    
    var thumbnailURL: NSURL? { get set }
    var thumbnailSize: LGSize? { get set }
    var imageURLs: [NSURL] { get set }
    
    var user: ProductUser? { get set }
    
    func formattedPrice() -> String
    func formattedDistance() -> String
}