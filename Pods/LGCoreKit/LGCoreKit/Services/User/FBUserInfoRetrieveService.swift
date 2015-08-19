//
//  FBUserInfoRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import FBSDKCoreKit
import Result

public enum FBUserInfoRetrieveServiceError {
    case General
    case Internal
}

public typealias FBUserInfoRetrieveServiceResult = (Result<FBUserInfo, FBUserInfoRetrieveServiceError>) -> Void

final public class FBUserInfoRetrieveService {
    
    // MARK: - FBUserInfoRetrieveService
    
    /**
        Retrieves the Facebook User information.
    
        :param: result The closure containing the result.
    */
    public func retrieveFBUserInfo(result: FBUserInfoRetrieveServiceResult?) {
        let meRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        meRequest.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection?, myResult: AnyObject?, error: NSError?) in
            // Error
            if let actualError = error {
                result?(Result<FBUserInfo, FBUserInfoRetrieveServiceError>.failure(.General))
            }
            // Success
            else if let responseDictionary = myResult as? NSDictionary {
                let fbUserInfo = FBUserInfoParser.fbUserInfoWithDictionary(responseDictionary)
                result?(Result<FBUserInfo, FBUserInfoRetrieveServiceError>.success(fbUserInfo))
            }
            // Other unhandled error
            else {
                result?(Result<FBUserInfo, FBUserInfoRetrieveServiceError>.failure(.Internal))
            }
        }
    }
}
