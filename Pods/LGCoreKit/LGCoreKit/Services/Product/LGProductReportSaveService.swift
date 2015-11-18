//
//  LGProductReportSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 03/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import Result

final public class LGProductReportSaveService: ProductReportSaveService {
    
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
    
    // MARK: - ProductReportSaveService
    
    public func saveReportProduct(product: Product, user: User, sessionToken: String, completion: ProductReportSaveServiceCompletion?) {
        
        let fullUrl = "\(url)/\(user.objectId!)/reports/products/\(product.objectId!)"
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.PUT, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (request, response, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductReportSaveServiceResult(error: .Network))
                    } else if let statusCode = response?.statusCode {
                        switch statusCode {
                        case 403:
                            completion?(ProductReportSaveServiceResult(error: .Forbidden))
                        default:
                            completion?(ProductReportSaveServiceResult(error: .Internal))
                        }
                    }
                    else {
                        completion?(ProductReportSaveServiceResult(error: .Internal))
                    }
                }
                // Success
                else {
                    completion?(ProductReportSaveServiceResult(value: Nil()))
                }
        }
    }
}

