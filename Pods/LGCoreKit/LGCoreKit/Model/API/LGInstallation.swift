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
        let init1 = curry(LGInstallation.init)
                            <^> j <|? keys.objectId
                            <*> j <| keys.appIdentifier
                            <*> j <| keys.appVersion
                            <*> j <| keys.deviceType
        let result = init1  <*> j <|? keys.timeZone
                            <*> j <|? keys.localeIdentifier
                            <*> j <|? keys.deviceToken

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.Parsing, message: "LGInstallation parse error: \(error)")
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
