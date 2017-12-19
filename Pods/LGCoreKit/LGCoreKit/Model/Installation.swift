//
//  Installation.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol Installation: BaseModel, UserDefaultsDecodable {
    var appIdentifier: String { get }
    var appVersion: String { get }
    var deviceType: String { get }
    var timeZone: String? { get }
    var localeIdentifier: String? { get }
    var deviceToken: String? { get }

    init(objectId: String?, appIdentifier: String, appVersion: String, deviceType: String, timeZone: String?, localeIdentifier: String?, deviceToken: String?)
}

struct InstallationAPIKeys {
    let objectId = "id"
    let appIdentifier = "app_identifier"
    let appVersion = "app_version"
    let deviceType = "device_type"
    let timeZone = "time_zone"
    let localeIdentifier = "locale_identifier"
    let deviceToken = "device_token"
}

struct InstallationUDKeys {
    static let objectId = "objectId"
    static let appIdentifier = "appIdentifier"
    static let appVersion = "appVersion"
    static let deviceType = "deviceType"
    static let userId = "userId"
    static let timeZone = "timeZone"
    static let localeIdentifier = "localeIdentifier"
    static let deviceToken = "deviceToken"
}

extension Installation {
    public static func decode(_ dictionary: [String: Any]) -> Self? {
        let objectId = dictionary[InstallationUDKeys.objectId] as? String
        let appIdentifier = dictionary[InstallationUDKeys.appIdentifier] as? String ?? ""
        let appVersion = dictionary[InstallationUDKeys.appVersion] as? String ?? ""
        let deviceType = dictionary[InstallationUDKeys.deviceType] as? String ?? ""
        let timeZone = dictionary[InstallationUDKeys.timeZone] as? String
        let localeIdentifier = dictionary[InstallationUDKeys.localeIdentifier] as? String
        let deviceToken = dictionary[InstallationUDKeys.deviceToken] as? String

        return self.init(objectId: objectId, appIdentifier: appIdentifier, appVersion: appVersion, deviceType: deviceType, timeZone: timeZone, localeIdentifier: localeIdentifier, deviceToken: deviceToken)
    }

    public func encode() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        dictionary[InstallationUDKeys.objectId] = objectId
        dictionary[InstallationUDKeys.appIdentifier] = appIdentifier
        dictionary[InstallationUDKeys.appVersion] = appVersion
        dictionary[InstallationUDKeys.deviceType] = deviceType
        dictionary[InstallationUDKeys.timeZone] = timeZone
        dictionary[InstallationUDKeys.localeIdentifier] = localeIdentifier
        dictionary[InstallationUDKeys.deviceToken] = deviceToken
        return dictionary
    }
}
