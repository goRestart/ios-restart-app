//
//  LGUserRetrieveService.swift
//  Pods
//
//  Created by Dídac on 21/09/15.
//
//

import Alamofire
import Result

final public class LGUserRetrieveService: UserRetrieveService {
    
    // Constants
    public static let endpoint = "/api/users"
    
    // iVars
    var url: String
    
    // MARK: - Lifecycle
    
    public init(baseURL: String) {
        self.url = baseURL + LGUserRetrieveService.endpoint
    }
    
    public convenience init() {
        self.init(baseURL: EnvironmentProxy.sharedInstance.apiBaseURL)
    }
    
    // MARK: - ProductsRetrieveService
    
//    {
//    "id": "PtGVQjpmZp",
//    "name": "Didac",
//    "avatar_url": "http://files.parsetfss.com/abbc9384-9790-4bbb-9db2-1c3522889e96/tfss-a52111eb-5b30-4d8c-839a-5780538499a1-file",
//    "zip_code": "08039",
//    "country_code": "ES",
//    "created_at": "2015-09-18T08:05:16+0000",
//    "updated_at": "2015-09-21T13:55:31+0000"
//    }
    public func retrieveUserWithId(userId: String, completion: UserRetrieveServiceCompletion?) {
        
        let fullUrl = "\(url)/\(userId)"
        let sessionToken : String = MyUserManager.sharedInstance.myUser()?.sessionToken ?? ""
        
        let headers = [
            LGCoreKitConstants.httpHeaderUserToken: sessionToken
        ]
        
        Alamofire.request(.GET, fullUrl, parameters: nil, headers: headers)
            .validate(statusCode: 200..<400)
            .responseObject { (userResponse: Response<LGUserResponse, NSError>) in
                // Error
                if let actualError = userResponse.result.error {
                    if actualError.domain == NSURLErrorDomain {
                        completion?(UserRetrieveServiceResult(error: .Network))
                    }
                    else {
                        completion?(UserRetrieveServiceResult(error: .Internal))
                    }
                }
                // Success
                else if let actualUserResponse = userResponse.result.value {
                    completion?(UserRetrieveServiceResult(value: actualUserResponse.user))
                }
            }
    }
}