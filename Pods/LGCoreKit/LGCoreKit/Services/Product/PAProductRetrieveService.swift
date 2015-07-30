//
//  PAProductRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

//import Parse
//
//final public class PAProductRetrieveService: ProductRetrieveService {
//    
//    // MARK: - ProductRetrieveService
//    
//    public func retrieveProductWithParams(params: RetrieveProductParams, completion: RetrieveProductCompletion?) {
//        var query = PFQuery(className: PAProduct.parseClassName())
//        query.whereKey(PAProduct.FieldKey.ObjectId.rawValue, equalTo: params.objectId)
//        query.limit = 1
//        query.includeKey(PAProduct.FieldKey.User.rawValue)
//        query.findObjectsInBackgroundWithBlock { [weak self] (objects: [AnyObject]?, error: NSError?) in
//            if let actualError = error {
//                completion?(product: nil, error: actualError)
//            }
//            else if let products = objects as? [PAProduct] {
//                if products.isEmpty {
//                    completion?(product: nil, error: NSError(code: LGErrorCode.Internal))
//                }
//                else {
//                    completion?(product: products.first!, error: NSError(code: LGErrorCode.Internal))
//                }
//            }
//            else {
//                completion?(product: nil, error: NSError(code: LGErrorCode.Internal))
//            }
//        }
//    }
//}