//
//  PAProductReportRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAProductReportRetrieveService: ProductReportRetrieveService {
    
    // MARK: - Lifecycle
    
    public init() {
    }
    
    // MARK: - ProductReportRetrieveService
    
    public func retrieveReportForProduct(product: Product, user: User, result: ProductReportRetrieveServiceResult?) {
        if let productId = product.objectId, let productOwnerId = product.user?.objectId, let userId = user.objectId {
            
            let theProduct = PAProduct(withoutDataWithObjectId: productId)
            let userReported = PFUser(withoutDataWithObjectId: productOwnerId)
            let userReporter = PFUser(withoutDataWithObjectId: userId)
            
            let query = PFQuery(className: PAProductReport.parseClassName())
            query.whereKey(PAProductReport.FieldKey.Product.rawValue, equalTo: theProduct)
            query.whereKey(PAProductReport.FieldKey.UserReported.rawValue, equalTo: userReported)
            query.whereKey(PAProductReport.FieldKey.UserReporter.rawValue, equalTo: userReporter)
            query.limit = 1
            query.findObjectsInBackgroundWithBlock { [weak self] (results: [AnyObject]?, error: NSError?) -> Void in
                if let actualResults = results as? [PAProductReport] {
                    // Success
                    if let productReport = actualResults.first {
                        result?(Result<ProductReport, ProductReportRetrieveServiceError>.success(productReport))
                    }
                    // Does not exist error
                    else {
                        result?(Result<ProductReport, ProductReportRetrieveServiceError>.failure(.DoesNotExist))
                    }
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<ProductReport, ProductReportRetrieveServiceError>.failure(.Network))
                    default:
                        result?(Result<ProductReport, ProductReportRetrieveServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<ProductReport, ProductReportRetrieveServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<ProductReport, ProductReportRetrieveServiceError>.failure(.Internal))
        }
    }
}
