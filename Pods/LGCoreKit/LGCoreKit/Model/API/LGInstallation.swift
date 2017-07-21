//
//  LGInstallation.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

protocol LGInstallationKeys {
    var objectId: String { get }
    var appIdentifier: String  { get }
    var appVersion: String  { get }
    var deviceType: String { get }
    var timeZone: String { get }
    var localeIdentifier: String { get }
    var deviceToken: String { get }
}

struct LGInstallation : Installation {
    var objectId: String?
    var appIdentifier: String
    var appVersion: String
    var deviceType: String
    var timeZone: String?
    var localeIdentifier: String?
    var deviceToken: String?
}

extension LGInstallation : Decodable {

    struct ApiInstallationKeys: LGInstallationKeys {
        let objectId = "id"
        let appIdentifier = "app_identifier"
        let appVersion = "app_version"
        let deviceType = "device_type"
        let timeZone = "time_zone"
        let localeIdentifier = "locale_identifier"
        let deviceToken = "device_token"
    }

    /**
    Expects a json in the form:

        {
            "id": "string",
            "app_identifier": "string",
            "app_version": "string",
            "device_type": "string",
            "user_id": "string",
            "time_zone": "string",
            "locale_identifier": "string",
            "device_token": "string",
            "device_token_last_modified": "string",
            "push_type": "string",
            "badge": 0,
            "created_at": "2015-12-03T17:50:59.923Z",
            "updated_at": "2015-12-03T17:50:59.923Z"
        }
    */
    static func decode(_ j: JSON) -> Decoded<LGInstallation> {
        return decode(j, keys: ApiInstallationKeys())
    }

    static func decode(_ j: JSON, keys: LGInstallationKeys) -> Decoded<LGInstallation> {
        let result1 = curry(LGInstallation.init)
        let result2 = result1 <^> j <|? keys.objectId
        let result3 = result2 <*> j <| keys.appIdentifier
        let result4 = result3 <*> j <| keys.appVersion
        let result5 = result4 <*> j <| keys.deviceType
        let result6 = result5 <*> j <|? keys.timeZone
        let result7 = result6 <*> j <|? keys.localeIdentifier
        let result  = result7 <*> j <|? keys.deviceToken
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGInstallation parse error: \(error)")
        }
        return result
    }
}

extension LGInstallation {

    struct UDInstallationKeys: LGInstallationKeys {
        let objectId = "objectId"
        let appIdentifier = "appIdentifier"
        let appVersion = "appVersion"
        let deviceType = "deviceType"
        let timeZone = "timeZone"
        let localeIdentifier = "localeIdentifier"
        let deviceToken = "deviceToken"
    }

    static func decode(_ dictionary: [String: Any]) -> LGInstallation? {
        let j = JSON(dictionary)
        return decode(j, keys: UDInstallationKeys()).value
    }
}
