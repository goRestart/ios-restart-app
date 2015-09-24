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
    
    
    public func retrieveUserProductRelationWithId(userId: String, productId: String, result: UserProductRelationServiceResult?) {
    
        var fullUrl = "\(url)/\(productId)/users/\(userId)"
        
        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.GET, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (_, _, relationResponse: LGUserProductRelationResponse?, error: NSError?) -> Void in
                // Error
                if let actualError = error {
                    let myError: NSError
                    if actualError.domain == NSURLErrorDomain {
                        result?(Result<UserProductRelation, UserProductRelationServiceError>.failure(.Network))
                    }
                    else {
                        result?(Result<UserProductRelation, UserProductRelationServiceError>.failure(.Internal))
                    }
                }
                    // Success
                else if let actualRelationResponse = relationResponse {
                    var relation = LGUserProductRelation()
                    relation.isFavorited = actualRelationResponse.isFavorited
                    relation.isReported = actualRelationResponse.isReported
                    result?(Result<UserProductRelation, UserProductRelationServiceError>.success(relation))
                }
        }
    }
}