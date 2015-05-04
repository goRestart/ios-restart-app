//
//  LGPartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

@objc public class LGPartialProduct: PartialProduct {
    
    // Constant
    // > JSON keys
    private static let objectIdJSONKey = "object_id"
    private static let createdAtJSONKey = "created_at"
    
    private static let nameJSONKey = "name"
    private static let priceJSONKey = "price"
    private static let currencyJSONKey = "currency"
    private static let distanceJSONKey = "distance"
    private static let distanceTypeJSONKey = "distance_type"
    
    private static let categoryIdJSONKey = "category_id"
    private static let statusJSONKey = "status"
    
    private static let thumbnailURLJSONKey = "img_url_thumb"
    private static let thumbnailSizeJSONKey = "image_dimensions"
    private static let widthJSONKey = "width"
    private static let heightJSONKey = "height"
    
    // PartialProduct iVars
    public var objectId: String?
    public var createdAt: NSDate?
    
    public var name: String
    public var price: Float?
    public var currency: Currency?
    public var distance: Float?
    public var distanceType: DistanceType?
    
    public var categoryId: Int?
    public var status: ProductStatus?
    
    public var thumbnailURL: String?
    public var thumbnailSize: LGSize?
    
    // MARK: - Lifecycle
    
    public init(name: String?) {
        if let actualName = name {
            self.name = actualName
        }
        else {
            self.name = ""
        }
    }
    
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
    public convenience init(json: JSON) {
        let name = json[LGPartialProduct.nameJSONKey].string
        self.init(name: name)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        if let objectId = json[LGPartialProduct.objectIdJSONKey].string {
            self.objectId = objectId
        }
        if let createdAtStr = json[LGPartialProduct.createdAtJSONKey].string {
            self.createdAt = dateFormatter.dateFromString(createdAtStr)
        }

        if let price = json[LGPartialProduct.priceJSONKey].string {
            self.price = (price as NSString).floatValue
        }
        if let currencyStr = json[LGPartialProduct.currencyJSONKey].string {
            self.currency = Currency.fromString(currencyStr)
        }
        if let distanceStr = json[LGPartialProduct.distanceJSONKey].string {
            self.distance = (distanceStr as NSString).floatValue
        }
        if let distanceTypeStr = json[LGPartialProduct.distanceTypeJSONKey].string {
            self.distanceType = DistanceType.fromString(distanceTypeStr)
        }
        if let categoryIdStr = json[LGPartialProduct.categoryIdJSONKey].string {
            self.categoryId = categoryIdStr.toInt()
        }
        if let statusStr = json[LGPartialProduct.statusJSONKey].string,
            let statusRaw = statusStr.toInt(),
            let status = ProductStatus(rawValue: statusRaw) {
                self.status = status
        }
        if let path = json[LGPartialProduct.thumbnailURLJSONKey].string {
            self.thumbnailURL = EnvironmentProxy.sharedInstance.apiBaseURL + "/images" + path
        }
        if let width = json[LGPartialProduct.thumbnailSizeJSONKey][LGPartialProduct.widthJSONKey].int,
            let height = json[LGPartialProduct.thumbnailSizeJSONKey][LGPartialProduct.heightJSONKey].int {
                self.thumbnailSize = LGSize(width: Float(width), height: Float(height))
        }
    }
}