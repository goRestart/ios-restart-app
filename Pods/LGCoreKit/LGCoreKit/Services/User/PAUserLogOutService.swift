//
//  PAUserLogOutService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

final public class PAUserLogOutService: UserLogOutService {
 
    public func logOutWithCompletion(completion: UserLogOutCompletion) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            if let actualError = error {
                completion(success: false, error: actualError)
            }
            else {
                completion(success: true, error: nil)
            }
        }
    }
}
