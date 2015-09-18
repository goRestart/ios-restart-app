//
//  PAProductReportSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAProductReportSaveService: ProductReportSaveService {
    
    // MARK: - Lifecycle
    
    public init() {
    }
    
    // MARK: - ProductReportSaveService
    
    public func saveReportProduct(product: Product, user: User, result: ProductReportSaveServiceResult?) {
        if let productId = product.objectId, let productOwnerId = product.user?.objectId, let userId = user.objectId {

            let productReport = PAProductReport()
            productReport.product = PAProduct(withoutDataWithObjectId: productId)
            productReport.userReported = PFUser(withoutDataWithObjectId: productOwnerId)
            productReport.userReporter = PFUser(withoutDataWithObjectId: userId)

            productReport.saveInBackgroundWithBlock { [weak self] (success: Bool, error: NSError?) -> Void in
                // Success
                if success {
                    result?(Result<Nil, ProductReportSaveServiceError>.success(Nil()))
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<Nil, ProductReportSaveServiceError>.failure(.Network))
                    default:
                        result?(Result<Nil, ProductReportSaveServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<Nil, ProductReportSaveServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<Nil, ProductReportSaveServiceError>.failure(.Internal))
        }
    }
}
