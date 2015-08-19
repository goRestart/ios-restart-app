//
//  PFACL+AccessControlList.swift
//  LGCoreKit
//
//  Created by Dídac on 24/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

extension PFACL: AccessControlList {
 
    // MARK: - AccessControlList
    
    public static func globalReadAccessACLWithWriteAccessForUserIds(userIds: [String]) -> AccessControlList {
        var acl = PFACL()
        acl.setPublicReadAccess(true)
        for userId in userIds {
            acl.setWriteAccess(true, forUserId: userId)
        }
        return acl
    }
}
