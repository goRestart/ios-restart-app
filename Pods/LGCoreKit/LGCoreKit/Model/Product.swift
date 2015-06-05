//
//  PartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreGraphics
import UIKit

@objc public protocol Product: BaseModel {
    var name: String? { get set }
    var descr: String? { get set }
    var price: NSNumber? { get set }
    var currencyCode: String? { get set }
    
    var location: LGLocationCoordinates2D? { get set }
    var distance: NSNumber? { get }
    var distanceType: DistanceType { get }
    
    var postalAddress: PostalAddress { get set }
    
    var languageCode: String? { get set }
        
    var categoryId: NSNumber? { get set }
    var status: ProductStatus { get set }
    
    var thumbnailURL: NSURL? { get }
    var thumbnailSize: LGSize? { get }
    var imageURLs: [NSURL] { get }
    
    var user: User? { get }
    
    var processed: NSNumber? { get set }
    
    func formattedPrice() -> String
    func formattedDistance() -> String
}