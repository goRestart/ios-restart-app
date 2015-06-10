//
//  PAUserSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

final public class PAUserSaveService: UserSaveService {
    
    // MARK: - Lifecycle
    
    public init() {

    }
    
    // MARK: - UserSaveService
    
    public func saveUser(user: User, completion: UserSaveCompletion) {
        if let parseUser = user as? PFUser {
            parseUser.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                completion(success: success, error: error)
            }
        }
        else {
            completion(success: false, error: NSError(code: LGErrorCode.Internal))
        }
    }
}


