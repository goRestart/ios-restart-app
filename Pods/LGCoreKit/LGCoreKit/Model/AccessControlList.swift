//
//  AccessControlList.swift
//  LGCoreKit
//
//  Created by Dídac on 24/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public protocol AccessControlList {
   
    /**
        Set whether the public is allowed to read this object.
    
        :param: allowed Whether the public can read this object.
    */
    func setPublicReadAccess(allowed: Bool)

    /**
        Set whether the given user id is allowed to write this object.
    
        :param: allowed Whether the given user can read this object.
        :param: userId The `objectId` of the user to assign access.
    */
    func setReadAccess(allowed: Bool, forUserId userId: String)
    
    /**
        Set whether the given user id is allowed to read this object.
    
        :param: allowed Whether the given user can write this object.
        :param: userId The <[PFObject objectId]> of the user to assign access.
    */
    func setWriteAccess(allowed: Bool, forUserId userId: String)
    
    /**
        Returns an AccessControlList with global read access and read-write for the given users ids.
    
        :param: userIds The user ids
        :return: An AccessControlList with global read access and read-write for the given users ids.
    */
    static func globalReadAccessACLWithWriteAccessForUserIds(userIds: [String]) -> AccessControlList
}
