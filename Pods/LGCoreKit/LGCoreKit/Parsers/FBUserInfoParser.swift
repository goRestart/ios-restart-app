//
//  FBUserInfoParser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class FBUserInfoParser {

    // Constant
    // > Graph request response dictionary keys
    private static let idDictKey = "id"
    private static let nameDictKey = "name"
    private static let firstNameDictKey = "first_name"
    private static let lastNameDictKey = "last_name"
    private static let emailDictKey = "email"

    public static func fbUserInfoWithDictionary(dictionary: NSDictionary) -> FBUserInfo {
        let facebookId = dictionary[FBUserInfoParser.idDictKey] as! String
        let name = dictionary[FBUserInfoParser.nameDictKey] as? String
        let firstName = dictionary[FBUserInfoParser.firstNameDictKey] as? String
        let lastName = dictionary[FBUserInfoParser.lastNameDictKey] as? String
        let email = dictionary[FBUserInfoParser.emailDictKey] as? String
        let avatarURL = NSURL(string: "https://graph.facebook.com/\(facebookId)/picture?type=large&return_ssl_resources=1")!
        return FBUserInfo(facebookId: facebookId, name: name, firstName: firstName, lastName: lastName, email: email, avatarURL: avatarURL)
    }
}
