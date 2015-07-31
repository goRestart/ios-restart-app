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
    
    public func deleteProductWithId(productId: String, sessionToken: String, result: ProductDeleteServiceResult?) {
        let productURL = "\(url)/\(productId)"
        var parameters = Dictionary<String, AnyObject>()
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        Alamofire.request(.DELETE, productURL, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (_, _, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    println(actualError)
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<Nil, ProductDeleteServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<Nil, ProductDeleteServiceError>.failure(.Internal))
                    }
                }
                // Success
                else {
                    result?(Result<Nil, ProductDeleteServiceError>.success(Nil()))
                }
        }
    }
}