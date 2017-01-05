//
//  MockInstallation.swift
//  LetGo
//
//  Created by Albert Hernández López on 17/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class MockInstallation: MockBaseModel, Installation {
    var appIdentifier: String
    var appVersion: String
    var deviceType: String
    var timeZone: String?
    var localeIdentifier: String?
    var deviceToken: String?


    // MARK: - Lifecycle

    override convenience init() {
        self.init(objectId: "12345", appIdentifier: "abcde", appVersion: "12345", deviceType: "ios", timeZone: "GMT+1",
            localeIdentifier: "es_ES", deviceToken: "12345")
    }

    required init(objectId: String?, appIdentifier: String, appVersion: String, deviceType: String, timeZone: String?,
        localeIdentifier: String?, deviceToken: String?) {
            self.appIdentifier = appIdentifier
            self.appVersion = appVersion
            self.deviceType = deviceType
            self.timeZone = timeZone
            self.localeIdentifier = localeIdentifier
            self.deviceToken = deviceToken
            super.init()

            self.objectId = objectId
    }
}

extension MockInstallation  {
    static func decode(dictionary: [String: Any]) -> Self? {
        let objectId = dictionary["objectId"] as? String
        let appIdentifier = dictionary["appIdentifier"] as? String ?? ""
        let appVersion = dictionary["appVersion"] as? String ?? ""
        let deviceType = dictionary["deviceType"] as? String ?? ""
        let timeZone = dictionary["timeZone"] as? String
        let localeIdentifier = dictionary["localeIdentifier"] as? String
        let deviceToken = dictionary["deviceToken"] as? String

        return self.init(objectId: objectId, appIdentifier: appIdentifier, appVersion: appVersion, deviceType: deviceType, timeZone: timeZone, localeIdentifier: localeIdentifier, deviceToken: deviceToken)
    }

    func encode() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary["objectId"] = objectId
        dictionary["appIdentifier"] = appIdentifier
        dictionary["appVersion"] = appVersion
        dictionary["deviceType"] = deviceType
        dictionary["timeZone"] = timeZone
        dictionary["localeIdentifier"] = localeIdentifier
        dictionary["deviceToken"] = deviceToken
        return dictionary
    }
}
