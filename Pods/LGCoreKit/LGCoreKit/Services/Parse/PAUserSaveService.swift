//
//  PAUserSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

final public class PAUserSaveService: UserSaveService {
    
    // MARK: - UserSaveService
    
    public func saveUser(user: MyUser, completion: UserSaveCompletion) {
        if let parseUser = user as? PFUser {
            parseUser.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                completion(success: success, error: error)
            }
        }
    }
}


