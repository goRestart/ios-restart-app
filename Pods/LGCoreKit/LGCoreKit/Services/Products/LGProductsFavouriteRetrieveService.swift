//
//  LGProductsFavouriteRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 02/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductsFavouriteRetrieveService: ProductsFavouriteRetrieveService {
    
    // Constants
    public static let endpoint = "/api/users"

    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        
        self.url = baseURL + LGProductsFavouriteRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductsRetrieveService
    
    public func retrieveFavouriteProducts(user: User, result: ProductsFavouriteRetrieveServiceResult?) {

        let fullUrl = "\(url)/\(user.objectId)/favorites/products"

        Alamofire.request(.GET, fullUrl, parameters: nil)
            .validate(statusCode: 200..<400)
            .responseObject { (request, response, productsFavouriteResponse: LGProductsFavouriteResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError: NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<ProductsFavouriteResponse, ProductsFavouriteRetrieveServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<ProductsFavouriteResponse, ProductsFavouriteRetrieveServiceError>.failure(.Internal))
                    }
                }
                // Success
                else if let actualProductsFavouriteResponse = productsFavouriteResponse {
                    result?(Result<ProductsFavouriteResponse, ProductsFavouriteRetrieveServiceError>.success(actualProductsFavouriteResponse))
                }
        }
    }
}

