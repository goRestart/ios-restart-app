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
 
    public func logOutUser(user: User, result: UserLogOutServiceResult?) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
            if let actualError = error {
                result?(Result<Nil, UserLogOutServiceError>.failure(.Internal))
            }
            else {
                result?(Result<Nil, UserLogOutServiceError>.success(Nil()))
            }
        }
    }
}
