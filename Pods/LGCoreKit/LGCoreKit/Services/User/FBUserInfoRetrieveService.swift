//
//  FBUserInfoRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import FBSDKCoreKit

final public class FBUserInfoRetrieveService {
    
    /**
        Retrieves the Facebook User information.
    
        :param: completion The completion closure.
    */
    public func retrieveFBUserInfo(completion: FBUserInfoRetrieveCompletion) {
        let meRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        meRequest.startWithCompletionHandler { (connection: FBSDKGraphRequestConnection?, result: AnyObject?, error: NSError?) in
            // Error
            if let actualError = error {
                completion(userInfo: nil, error: error)
            }
            // Success
            else if let responseDictionary = result as? NSDictionary {
                let fbUserInfo = FBUserInfoParser.fbUserInfoWithDictionary(responseDictionary)
                completion(userInfo: fbUserInfo, error: nil)
            }
            // Other unhandled error
            else {
                completion(userInfo: nil, error: NSError(code: LGErrorCode.Internal))
            }
        }
    }
}
