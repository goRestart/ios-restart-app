//
//  LGProductFavouriteSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 03/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductFavouriteSaveService: ProductFavouriteSaveService {
    
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
    
    // MARK: - ProductFavouriteSaveService
    
    public func saveFavouriteProduct(product: Product, user: User, sessionToken: String, result: ProductFavouriteSaveServiceResult?) {
    
        let fullUrl = "\(url)/\(user.objectId)/favorites/products/\(product.objectId)"
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.PUT, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (_, response, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError : NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.failure(.Internal))
                    }
                } else {
                    var prodFav = LGProductFavourite()
                    prodFav.product = product
                    prodFav.user = user
                    result?(Result<ProductFavourite, ProductFavouriteSaveServiceError>.success(prodFav))
                }
        }
    }
}
