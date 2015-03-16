//
//  MyProductsManager.swift
//  Ambatana
//
//  Created by AHL on 16/3/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

protocol MyProductsManager {
    class func retrieveProductsForUserId(userId: String?, status: Int, completion: (objects: [Product]!, error: NSError!) -> (Void))
    class func retrieveFavouriteProductsForUserId(userId: String?, completion: (products: [Product]!, error: NSError!) -> (Void))
}

class PFProductManager {
    class func retrieveProductsForUserId(userId: String?, status: ProductStatus, completion: (products: [Product]!, error: NSError!) -> (Void)) {
        let user = PFObject(withoutDataWithClassName: "_User", objectId: userId)
        let query = PFQuery(className: PFProduct.parseClassName())
        query.whereKey(PFProduct.FieldKey.User.rawValue, equalTo: user)
        query.whereKey(PFProduct.FieldKey.Status.rawValue, equalTo: status.rawValue)
        query.orderByDescending(PFProduct.FieldKey.CreatedAt.rawValue)
        query.findObjectsInBackgroundWithBlock( { (objects, error) -> Void in
            let products = objects as [PFProduct]!
            completion(products: products, error: error)
        })
    }
    
    class func retrieveFavouriteProductsForUserId(userId: String?, completion: (favProducts: [Product]!, error: NSError!) -> (Void)) {
        let user = PFObject(withoutDataWithClassName: "_User", objectId: userId)
        let query = PFQuery(className: PFFavProduct.parseClassName())
        query.whereKey(PFFavProduct.FieldKey.User.rawValue, equalTo: user)
        query.orderByDescending(PFFavProduct.FieldKey.CreatedAt.rawValue)
        query.includeKey(PFFavProduct.FieldKey.Product.rawValue)
        query.findObjectsInBackgroundWithBlock( { (objects, error) -> Void in
            var favProducts = objects as [PFFavProduct]!
            var products: [Product]! = []
            for favProduct in favProducts {
                products.append(favProduct.product!)
            }
            completion(favProducts: products, error: error)
        })
    }
}