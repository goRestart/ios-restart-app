//
//  LGProductMarkSoldService.swift
//  LGCoreKit
//
//  Created by Dídac on 04/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductMarkSoldService: ProductMarkSoldService {
    
    // Constants
    public static let endpoint = "/api/products"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        
        self.url = baseURL + LGProductMarkSoldService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }

    // MARK: - ProductMarkSoldService
    
    public func markAsSoldProduct(product: Product, sessionToken: String, result: ProductMarkSoldServiceResult?) {
        
        let fullUrl = "\(url)/\(product.objectId)"
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        var params = Dictionary<String, AnyObject>()
        
        params["status"] = ProductStatus.Sold.rawValue // NSNumber(integer: )
        
        Alamofire.request(.PATCH, fullUrl, parameters: params, encoding: .JSON, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (request, response, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError : NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<Product, ProductMarkSoldServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
                    }
                } else {
                    result?(Result<Product, ProductMarkSoldServiceError>.success(product))
                }
        }
        
    }
}
