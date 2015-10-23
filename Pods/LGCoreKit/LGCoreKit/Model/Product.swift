//
//  PartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreGraphics
import UIKit

public protocol Product: BaseModel {
    var name: String? { get set }
    var descr: String? { get set }
    var price: NSNumber? { get set }
    var currency: Currency? { get set }
    
    var location: LGLocationCoordinates2D? { get set }
    var postalAddress: PostalAddress { get set }
    
    var languageCode: String? { get set }
        
    var categoryId: NSNumber? { get set }   // TODO: To be refactored to user ProductCategory when @objc is removed
    var status: ProductStatus { get set }
    
    var thumbnail: File? { get set }
    var thumbnailSize: LGSize? { get }
    var images: [File] { get set }
    
    var user: User? { get set }
    
    var reported: NSNumber? { get set }
    var favorited: NSNumber? { get set }

    func formattedPrice() -> String
    func updateWithProduct(product: Product )
}