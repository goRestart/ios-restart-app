//
//  LGUserProductsRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 09/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Alamofire
import Result

final public class LGUserProductsRetrieveService: UserProductsRetrieveService {
    
    // Constants
    public static let endpoint = "/api/users"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        
        self.url = baseURL + LGUserProductsRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductsRetrieveService
    
    public func retrieveUserProductsWithParams(params: RetrieveProductsParams, result: ProductsRetrieveServiceResult?) {
        
        var fullUrl = ""
        if let userId = params.userObjectId {
            fullUrl = "\(url)/\(userId)/products"
        } else {
            result?(Result<ProductsResponse, ProductsRetrieveServiceError>.failure(.Internal))
        }
        
        let parameters = params.userProductApiParams
        
        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]

        Alamofire.request(.GET, fullUrl, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (request, response, productsResponse: LGProductsResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError: NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<ProductsResponse, ProductsRetrieveServiceError>.failure(.Network))
                    } else if let statusCode = response?.statusCode {
                        switch statusCode {
                        case 403:
                            result?(Result<ProductsResponse, ProductsRetrieveServiceError>.failure(.Forbidden))
                        default:
                            result?(Result<ProductsResponse, ProductsRetrieveServiceError>.failure(.Internal))
                        }
                    }
                    else {
                        result?(Result<ProductsResponse, ProductsRetrieveServiceError>.failure(.Internal))
                    }
                }
                    // Success
                else if let actualProductsResponse = productsResponse {
                    result?(Result<ProductsResponse, ProductsRetrieveServiceError>.success(actualProductsResponse))
                }
        }
    }
}

extension RetrieveProductsParams {
    var userProductApiParams: Dictionary<String, AnyObject> {
        get {
            var params = Dictionary<String, AnyObject>()
            
            if let numRes = self.numProducts {
                params["num_results"] = numRes
            }
            
            if let offset = self.offset {
                params["offset"] = offset
            }

            // TODO: Think twice about this :-P
            if self.statuses == [.Sold, .SoldOld] {
                params["status"] = UserProductStatus.Sold.rawValue
            } else {
                params["status"] = UserProductStatus.Selling.rawValue
            }
            
            return params

        }
    }
}