//
//  LGProductDeleteService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductDeleteService: ProductDeleteService {
    
    // Constants
    public static let endpoint = "/api/products"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGProductDeleteService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductDeleteService
    
    public func deleteProduct(product: Product, sessionToken: String, completion: ProductDeleteServiceCompletion?) {
        let productURL = "\(url)/\(product.objectId!)"
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.request(.DELETE, productURL, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (_, _, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductDeleteServiceResult(error: .Network))
                    }
                    else {
                        completion?(ProductDeleteServiceResult(error: .Internal))
                    }
                }
                // Success
                else {
                    var result = LGProduct(product: product)
                    result.status = .Deleted
                    completion?(ProductDeleteServiceResult(value: result))
                }
        }
    }
}