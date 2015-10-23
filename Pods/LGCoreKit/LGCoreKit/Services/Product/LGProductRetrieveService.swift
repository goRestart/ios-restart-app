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
    

    public func retrieveProductWithId(productId: String, completion: ProductRetrieveServiceCompletion?) {
        
        let fullUrl = "\(url)/\(productId)"

        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.GET, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (response: Response<LGProductResponse, NSError>) -> Void in
                // Success
                if let productResponse = response.result.value {
                    completion?(ProductRetrieveServiceResult(value: productResponse.product))
                }
                // Error
                else if let actualError = response.result.error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductRetrieveServiceResult(error: .Network))
                    }
                    else {
                        completion?(ProductRetrieveServiceResult(error: .Internal))
                    }
                }
            }
        }
}

