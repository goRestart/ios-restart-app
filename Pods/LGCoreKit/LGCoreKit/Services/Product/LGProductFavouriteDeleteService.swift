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
    
    public func deleteProductFavourite(productFavourite: ProductFavourite, sessionToken: String, completion: ProductFavouriteDeleteServiceCompletion?) {
        
            
        let fullUrl = "\(url)/\(productFavourite.user.objectId!)/favorites/products/\(productFavourite.product.objectId!)"
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.DELETE, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (_, response, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductFavouriteDeleteServiceResult(error: .Network))
                    }
                    else {
                        completion?(ProductFavouriteDeleteServiceResult(error: .Internal))
                    }
                }
                // Success
                else {
                    if response?.statusCode == 204 {
                        // success
                        completion?(ProductFavouriteDeleteServiceResult(value: Nil()))
                    } else {
                        // error
                        completion?(ProductFavouriteDeleteServiceResult(error: .Internal))
                    }
                }
        }
        
    }

}
