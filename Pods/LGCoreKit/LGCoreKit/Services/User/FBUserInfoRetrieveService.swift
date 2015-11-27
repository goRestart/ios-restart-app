//
//  FBUserInfoRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import FBSDKCoreKit
import Result

public enum FBUserInfoRetrieveServiceError: ErrorType {
    case General
    case Internal
}

public typealias FBUserInfoRetrieveServiceResult = Result<FBUserInfo, FBUserInfoRetrieveServiceError>
public typealias FBUserInfoRetrieveServiceCompletion = FBUserInfoRetrieveServiceResult -> Void

public class FBUserInfoRetrieveService {
    
    // MARK: - Lifecycle
    
    public init() {
    }
    
    // MARK: - FBUserInfoRetrieveService
    
    /**
        Retrieves the Facebook User information.
    
        - parameter completion: The completion closure.
    */
    public func retrieveFBUserInfoWithCompletion(completion: FBUserInfoRetrieveServiceCompletion?) {
        let parameters = ["fields": "id ,name, first_name, last_name, email"]
        let meRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        meRequest.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection?, myResult: AnyObject?, error: NSError?) in
            // Error
            if let _ = error {
                completion?(FBUserInfoRetrieveServiceResult(error: .General))
            }
            // Success
            else if let responseDictionary = myResult as? NSDictionary {
                let fbUserInfo = FBUserInfoParser.fbUserInfoWithDictionary(responseDictionary)
                completion?(FBUserInfoRetrieveServiceResult(value: fbUserInfo))
            }
            // Other unhandled error
            else {
                completion?(FBUserInfoRetrieveServiceResult(error: .Internal))
            }
        }
    }
}
