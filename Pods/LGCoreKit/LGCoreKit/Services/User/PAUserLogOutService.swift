//
//  PAUserLogOutService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAUserLogOutService: UserLogOutService {
 
    // MARK: - UserLogOutService
    
    public func logOutUser(user: User, completion: UserLogOutServiceCompletion?) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            if let _ = error {
                completion?(UserLogOutServiceResult(error: .Internal))
            }
            else {
                completion?(UserLogOutServiceResult(value: Nil()))
            }
        }
    }
}
