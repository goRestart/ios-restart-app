//
//  PAMyUserRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 19/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Parse

final class PAMyUserRetrieveService: MyUserRetrieveService {
    
    // MARK: - MyUserRetrieveService
    
    func retrieveMyUserWithSessionToken(sessionToken: String, myUserId: String, completion: MyUserRetrieveServiceCompletion?) {
        let query = PFQuery(className: PFUser.parseClassName())
        query.whereKey(PFObject.FieldKey.ObjectId.rawValue, equalTo:myUserId)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            
            // Success
            if let users = objects as? [PFUser], let user = users.first {
                completion?(MyUserRetrieveServiceResult(value: user))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    completion?(MyUserRetrieveServiceResult(error: .Network))
                default:
                    completion?(MyUserRetrieveServiceResult(error: .Internal))
                }
            }
            else {
                completion?(MyUserRetrieveServiceResult(error: .Internal))
            }
        }
    }
}