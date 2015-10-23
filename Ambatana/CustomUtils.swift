//
//  CustomUtils.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 06/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import LGCoreKit
import UIKit
import Parse

/**  Uses regular expressions to test whether a string is a valid email */
extension String {
    func isEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
}

/**  Uses regular expressions to test whether a string is a valid username */
extension String {
    func isValidUsername() -> Bool {
        let tmpString = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return tmpString.characters.count > 1
    }
}

/**  Uses regular expressions to test whether a string is a valid price */
extension String {
    func isValidPrice() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[0-9]+[\\.,]{0,1}[0-9]{0,2}$", options: .CaseInsensitive)
        return regex?.firstMatchInString(self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }
}

/**
 * Generates a Parse PFACL object giving all permissions to the current user and global read access.
 */
func globalReadAccessACL() -> PFACL {
    let acl = PFACL(user: PFUser.currentUser()!)
    acl.setPublicReadAccess(true)
    return acl
}

/**
 * Generates a Parse PFACL object giving all permissions to the current user and global read access,
 * grant also write permission to selectedUsers.
 */
func globalReadAccessACLWithWritePermissionForUsers(selectedUsers: [PFUser]) -> PFACL {
    let acl = globalReadAccessACL()
    for selectedUser in selectedUsers {
        acl.setWriteAccess(true, forUser: selectedUser)
    }
    return acl
}

/**
 * Returns a valid dispatch_time of secs seconds.
 */
func dispatchTimeForSeconds(secs: Double) -> dispatch_time_t {
    return dispatch_time(DISPATCH_TIME_NOW, Int64(secs * Double(NSEC_PER_SEC)))
}

