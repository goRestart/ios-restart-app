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

/** Checks if the iOS version is at least "version" */
func iOSVersionAtLeast(version: String) -> Bool {
    // TODO: Revert the iOS 7 method when supporting it back.
    return true
    
    switch UIDevice.currentDevice().systemVersion.compare(version, options: NSStringCompareOptions.NumericSearch) {
    case .OrderedSame, .OrderedDescending:
        return true
    case .OrderedAscending:
        return false
    }
}

/**  Uses regular expressions to test whether a string is a valid email */
extension String {
    func isEmail() -> Bool {
        let regex = NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]+$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
    }
}

/**  Uses regular expressions to test whether a string is a valid username */
extension String {
    func isValidUsername() -> Bool {
        var tmpString = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return count(tmpString) > 1
    }
}

/**  Uses regular expressions to test whether a string is a valid price */
extension String {
    func isValidPrice() -> Bool {
        let regex = NSRegularExpression(pattern: "^[0-9]+[\\.,]{0,1}[0-9]{0,2}$", options: .CaseInsensitive, error: nil)
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, count(self))) != nil
    }
}

/**
 * Link for an LetGo product in the website.
 */
func letgoWebLinkForObjectId(objectId: String) -> String {
    return "http://www.letgo.com/product/\(objectId)"
}

/**
 * Text for the message body when sharing a product in LetGo.
 */
func letgoTextForSharingBody(productName: String, userName: String, andObjectId objectId: String) -> String {
    return NSLocalizedString("product_share_body", comment: "") + "\n" + userName + " - " + productName + ":\n" + letgoWebLinkForObjectId(objectId)
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
* Retrieves a query for all the categories in a concrete language.
*/
func allCategoriesQueryForLanguage(language: String) -> PFQuery {
    // the external query will retrieve all favorite categories where the category number matches the inner query.
    let query = PFQuery(className: "Categories")
    query.whereKey("language_code", equalTo: language)
    query.orderByAscending("category_id")
    return query
}

/**
* Retrieves a Query for the user's favorite categories, in a concrete language code.
*/
func favoriteCategoriesQuery() -> PFQuery {
    // inner query. Get all favorite category identifiers.
    let innerQuery = PFQuery(className: "UserFavoriteCategories")
    innerQuery.whereKey("user", equalTo: PFUser.currentUser()!)
    
    // the external query will retrieve all favorite categories where the category number matches the inner query.
    let query = PFQuery(className: "Categories")
    query.whereKey("category_id", matchesKey: "category_id", inQuery: innerQuery)
    return query
}

/**
 * Gets the height of the status bar
 */
func statusBarHeight() -> CGFloat {
    let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
    return Swift.min(statusBarSize.width, statusBarSize.height)
}

/**
 * Returns a valid dispatch_time of secs seconds.
 */
func dispatchTimeForSeconds(secs: Double) -> dispatch_time_t {
    return dispatch_time(DISPATCH_TIME_NOW, Int64(secs * Double(NSEC_PER_SEC)))
}

