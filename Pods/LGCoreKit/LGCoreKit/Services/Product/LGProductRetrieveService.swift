//
//  LGProductRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 07/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductRetrieveService: ProductRetrieveService {
   
    // Constants
    public static let endpoint = "/api/products"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGProductRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductsRetrieveService
    

    public func retrieveProductWithId(productId: String, result: ProductRetrieveServiceResult?) {
        
        var fullUrl = "\(url)/\(productId)"

        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.GET, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (_, _, productResponse: LGProductResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError: NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<Product, ProductRetrieveServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<Product, ProductRetrieveServiceError>.failure(.Internal))
                    }
                }
                // Success
                else if let actualProductResponse = productResponse {
                    result?(Result<Product, ProductRetrieveServiceError>.success(actualProductResponse.product))
                }
        }
    }
}
