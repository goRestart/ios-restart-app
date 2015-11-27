//
//  LGProductMarkUnsoldService.swift
//  LGCoreKit
//
//  Created by Dídac on 02/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductMarkUnsoldService: ProductMarkUnsoldService {
    
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
    
    public func markAsUnsoldProduct(product: Product, sessionToken: String, completion: ProductMarkUnsoldServiceCompletion?) {
        
        guard let productId = product.objectId else {
            completion?(ProductMarkUnsoldServiceResult(error: .Internal))
            return
        }
        
        let fullUrl = "\(url)/\(productId)"
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        var params = Dictionary<String, AnyObject>()
        params["status"] = ProductStatus.Approved.rawValue
        
        Alamofire.request(.PATCH, fullUrl, parameters: params, encoding: .JSON, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (request, response, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductMarkUnsoldServiceResult(error: .Network))
                    }
                    else {
                        completion?(ProductMarkUnsoldServiceResult(error: .Internal))
                    }
                } else {
                    var result = LGProduct(product: product)
                    result.status = .Approved
                    completion?(ProductMarkUnsoldServiceResult(value: result))
                }
        }
    }
}
