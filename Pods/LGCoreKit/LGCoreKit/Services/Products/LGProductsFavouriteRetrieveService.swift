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
    
    public func retrieveFavouriteProducts(user: User, completion: ProductsFavouriteRetrieveServiceCompletion?) {

        let fullUrl = "\(url)/\(user.objectId!)/favorites/products"
        
        Alamofire.request(.GET, fullUrl, parameters: nil)
            .validate(statusCode: 200..<400)
            .responseObject { (productsFavouriteResponse: Response<LGProductsFavouriteResponse, NSError>) -> Void in
                // Error
                if let actualError = productsFavouriteResponse.result.error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductsFavouriteRetrieveServiceResult(error: .Network))
                    }
                    else {
                        completion?(ProductsFavouriteRetrieveServiceResult(error: .Internal))
                    }
                }
                // Success
                else if let actualProductsFavouriteResponse = productsFavouriteResponse.result.value {
                    completion?(ProductsFavouriteRetrieveServiceResult(value: actualProductsFavouriteResponse))
                }
            }
    }
}