//
//  CustomUtils.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 06/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

/** Checks if the iOS version is at least "version" */
func iOSVersionAtLeast(version: String) -> Bool {
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
        return regex?.firstMatchInString(self, options: nil, range: NSMakeRange(0, countElements(self))) != nil
    }
}

/**
 * Link for an Ambatana product in the website.
 */
func ambatanaWebLinkForObjectId(objectId: String) -> String {
    return "http://www.ambatana.com/product/\(objectId)"
}

/**
 * Text for the message body when sharing a product in Ambatana.
 */
func ambatanaTextForSharingBody(productName: String, andObjectId objectId: String) -> String {
    return translate("have_a_look") + productName // + "\n" + ambatanaWebLinkForObjectId(objectId)
}

/**
 * Localizes a text based on a localized string.
 */
func translate(text: String) -> String {
    return NSLocalizedString(text, comment: "")
}

/**
 * Localizes a text with a given format, following the println argument type specifications.
 * Example: translateWithFormat("x_seconds_ago", numSeconds)
 * If "x_seconds_ago" is defined in spanish as "hace %d segundos" and as "%d seconds ago" in english, the result would be
 * "hace numSeconds segundos" in spanish and "numSeconds seconds ago" in english.
 */
func translateWithFormat(text: String, parameters: [CVarArgType]) -> String {
    return String(format: NSLocalizedString(text, comment: ""), arguments: parameters)
}

/**
 * Generates a Parse PFACL object giving all permissions to the current user and global read access.
 */
func globalReadAccessACL() -> PFACL {
    let acl = PFACL(user: PFUser.currentUser())
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
    return query
}

/**
* Retrieves a Query for the user's favorite categories, in a concrete language code.
*/
func favoriteCategoriesQuery() -> PFQuery {
    // inner query. Get all favorite category identifiers.
    let innerQuery = PFQuery(className: "UserFavoriteCategories")
    innerQuery.whereKey("user", equalTo: PFUser.currentUser())
    
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
 * Returns a string containing the distance of the current user to a given point from a PFGeoPoint
 */
func distanceStringToGeoPoint(geoPoint: PFGeoPoint) -> String {
    if let currentUserGeoPoint = PFUser.currentUser()?["gpscoords"] as? PFGeoPoint {
        let km = geoPoint.distanceInKilometersTo(currentUserGeoPoint)
        if km > 1.0 {
            return NSString(format: "%.1fKm", km)
        }
        else {
            let m: Int = Int(km * 1000)
            if m > 1 {
                return "\(m)m"
            }
            else {
                return translate("here")
            }
        }
    } else { return translate("unknown_distance") }

}

