//
//  LGProductFavouriteDeleteService.swift
//  LGCoreKit
//
//  Created by Dídac on 03/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductFavouriteDeleteService: ProductFavouriteDeleteService {
   
    // Constants
    public static let endpoint = "/api/users"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        
        self.url = baseURL + LGProductFavouriteSaveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductFavouriteDeleteService
    
    public func deleteProductFavourite(productFavourite: ProductFavourite, sessionToken: String, result: ProductFavouriteDeleteServiceResult?) {
        
        if let user = productFavourite.user, let product = productFavourite.product {
            
            let fullUrl = "\(url)/\(user.objectId)/favorites/products/\(product.objectId)"
            
            let headers = [
                LGCoreKitConstants.httpHeaderUserToken: sessionToken
            ]
            
            Alamofire.request(.DELETE, fullUrl, parameters: nil, headers: headers)
                .validate(statusCode: 200..<400)
                .response { (_, response, _, error: NSError?) -> Void in
                    // Error
                    if let actualError = error {
                        let myError : NSError
                        if actualError.domain == NSURLErrorDomain {
                            result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Network))
                        }
                        else {
                            result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
                        }
                    }
                    // Success
                    else {
                        if response?.statusCode == 204 {
                            // success
                            result?(Result<Nil, ProductFavouriteDeleteServiceError>.success(Nil()))
                        } else {
                            // error
                            result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
                        }
                    }
            }
            
        } else {
            // Error no user or product
            result?(Result<Nil, ProductFavouriteDeleteServiceError>.failure(.Internal))
        }
        
    }

}
