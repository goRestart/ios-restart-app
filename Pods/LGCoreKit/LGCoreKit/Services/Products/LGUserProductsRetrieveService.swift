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
    
    public func retrieveUserProductsWithParams(params: RetrieveProductsParams, completion: ProductsRetrieveServiceCompletion?) {
        
        var fullUrl = ""
        if let userId = params.userObjectId {
            fullUrl = "\(url)/\(userId)/products"
        } else {
            completion?(ProductsRetrieveServiceResult(error: .Internal))
        }
        
        let parameters = params.userProductApiParams
        
        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]

        Alamofire.request(.GET, fullUrl, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject {  (productsResponse: Response<LGProductsResponse, NSError>) in
                // Error
                if let actualError = productsResponse.result.error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(ProductsRetrieveServiceResult(error: .Network))
                    } else if let statusCode = productsResponse.response?.statusCode {
                        switch statusCode {
                        case 403:
                            completion?(ProductsRetrieveServiceResult(error: .Forbidden))
                        default:
                            completion?(ProductsRetrieveServiceResult(error: .Internal))
                        }
                    }
                    else {
                        completion?(ProductsRetrieveServiceResult(error: .Internal))
                    }
                }
                // Success
                else if let actualProductsResponse = productsResponse.result.value {
                    completion?(ProductsRetrieveServiceResult(value: actualProductsResponse))
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