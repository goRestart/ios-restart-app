//
//  PAUserRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

//import Parse
//
//final public class PAUserRetrieveService: UserRetrieveService {
//
//    // MARK: - Lifecycle
//
//    public init() {
//
//    }
//
//    // MARK: - UserSaveService
//
//    public func retrieveUser(user: User, completion: UserRetrieveCompletion) {
//        if let parseUser = user as? PFUser {
//            parseUser.fetchInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
//                if let actualError = error {
//                    completion(user: nil, error: actualError)
//                }
//                else if let fullUser = object as? PFUser {
//                    completion(user: fullUser, error: nil)
//                }
//                else {
//                    completion(user: nil, error: NSError(code: LGErrorCode.Internal))
//                }
//            }
//        }
//    }
//}
