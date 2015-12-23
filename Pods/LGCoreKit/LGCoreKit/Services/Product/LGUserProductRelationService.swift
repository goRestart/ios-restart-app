//
//  LGUserProductRelationService.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Alamofire
import Result

final public class LGUserProductRelationService: UserProductRelationService {
    
    // Constants
    public static let endpoint = "/api/products"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGUserProductRelationService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductsRetrieveService
    
    public func retrieveUserProductRelationWithId(userId: String, productId: String, completion: UserProductRelationServiceCompletion?) {
    
        let fullUrl = "\(url)/\(productId)/users/\(userId)"
        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.GET, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (relationResponse: Response<LGUserProductRelationResponse, NSError>) -> Void in
                // Error
                if let actualError = relationResponse.result.error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(UserProductRelationServiceResult(error: .Network))
                    }
                    else {
                        completion?(UserProductRelationServiceResult(error: .Internal))
                    }
                }
                // Success
                else if let actualRelationResponse = relationResponse.result.value {
                    completion?(UserProductRelationServiceResult(value: actualRelationResponse.userProductRelation))
                }
            }
    }
}