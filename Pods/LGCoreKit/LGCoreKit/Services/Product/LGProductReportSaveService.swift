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
    
    public func saveReportProduct(product: Product, user: User, sessionToken: String, result: ProductReportSaveServiceResult?) {
        
        let fullUrl = "\(url)/\(user.objectId)/reports/products/\(product.objectId)"
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.PUT, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .response { (request, response, _, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError : NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<Nil, ProductReportSaveServiceError>.failure(.Network))
                    } else if let statusCode = response?.statusCode {
                        switch statusCode {
                        case 403:
                            result?(Result<Nil, ProductReportSaveServiceError>.failure(.Forbidden))
                        default:
                            result?(Result<Nil, ProductReportSaveServiceError>.failure(.Internal))
                        }
                    }
                    else {
                        result?(Result<Nil, ProductReportSaveServiceError>.failure(.Internal))
                    }
                } else {
                    result?(Result<Nil, ProductReportSaveServiceError>.success(Nil()))
                }
        }
    }
}

