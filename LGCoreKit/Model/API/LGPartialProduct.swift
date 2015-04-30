//
//  LGPartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

public struct LGPartialProduct: PartialProduct {
    
    // MARK: - PartialProduct
    
    public var objectId: String?
    public var createdAt: NSDate?
    
    public var name: String?
    public var price: Float?
    public var currency: Currency?
    public var distance: String?
    public var distanceType: DistanceType?
    
    public var categoryId: String?
    public var status: ProductStatus?
    
    public var thumbnailURL: String?
    public var thumbnailSize: LGSize?
}

//protocol PartialProduct {
//    var objectId: String? { get set }
//    var createdAt: NSDate? { get set }
//    
//    var name: String? { get set }
//    var price: Float? { get set }
//    var currency: Currency? { get set }
//    var distance: String? { get set }
//    var distanceType: DistanceType? { get set }
//    
//    var categoryId: String? { get set }
//    var status: ProductStatus? { get set }
//    
//    var thumbnailURL: String? { get set }
//    var thumbnailSize: Size? { get set }
//}


//{
//    "object_id": "fYAHyLsEVf",
//    "category_id": "4",
//    "name": "Calentador de agua",
//    "price": "80",
//    "currency": "EUR",
//    "created_at": "2015-04-15 10:12:21",
//    "status": "1",
//    "img_url_thumb": "/50/a2/f4/5f/b8ede3d0f6afacde9f0001f2a2753c6b_thumb.jpg",
//    "distance_type": "ML",
//    "distance": "9.65026566268547",
//    "image_dimensions": {
//        "width": 200,
//        "height": 150
//    }
//}