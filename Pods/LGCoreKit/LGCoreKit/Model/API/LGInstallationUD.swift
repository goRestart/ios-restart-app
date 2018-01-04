//
//  LGInstallationUD.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 03/11/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

struct LGInstallationUD: Installation, Codable {
    public var objectId: String?
    public var appIdentifier: String
    public var appVersion: String
    public var deviceType: String
    public var timeZone: String?
    public var localeIdentifier: String?
    public var deviceToken: String?
    
    public init(objectId: String?, appIdentifier: String, appVersion: String, deviceType: String, timeZone: String?,
                localeIdentifier: String?, deviceToken: String?) {
        self.objectId = objectId
        self.appIdentifier = appIdentifier
        self.appVersion = appVersion
        self.deviceType = deviceType
        self.timeZone = timeZone
        self.localeIdentifier = localeIdentifier
        self.deviceToken = deviceToken
    }
    
    public init?(dictionary: [String: Any]) {
        guard let appIdentifier = dictionary[CodingKeys.appIdentifier.rawValue] as? String,
            let appVersion = dictionary[CodingKeys.appVersion.rawValue] as? String,
            let deviceType = dictionary[CodingKeys.deviceType.rawValue] as? String else {
                return nil
        }
        
        self.appIdentifier = appIdentifier
        self.appVersion = appVersion
        self.deviceType = deviceType
        objectId = dictionary[CodingKeys.objectId.rawValue] as? String
        timeZone = dictionary[CodingKeys.timeZone.rawValue] as? String
        localeIdentifier = dictionary[CodingKeys.localeIdentifier.rawValue] as? String
        deviceToken = dictionary[CodingKeys.deviceToken.rawValue] as? String
    }
    
    public static func makeInstallationUD(from installation: Installation) -> LGInstallationUD {
        return LGInstallationUD(objectId: installation.objectId,
                                appIdentifier: installation.appIdentifier,
                                appVersion: installation.appVersion,
                                deviceType: installation.deviceType,
                                timeZone: installation.timeZone,
                                localeIdentifier: installation.localeIdentifier,
                                deviceToken: installation.deviceToken)
    }
}

extension LGInstallationUD {
    
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
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decodeIfPresent(String.self, forKey: .objectId)
        appIdentifier = try keyedContainer.decode(String.self, forKey: .appIdentifier)
        appVersion = try keyedContainer.decode(String.self, forKey: .appVersion)
        deviceType = try keyedContainer.decode(String.self, forKey: .deviceType)
        timeZone = try keyedContainer.decodeIfPresent(String.self, forKey: .timeZone)
        localeIdentifier = try keyedContainer.decodeIfPresent(String.self, forKey: .localeIdentifier)
        deviceToken = try keyedContainer.decodeIfPresent(String.self, forKey: .deviceToken)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(objectId, forKey: .objectId)
        try container.encode(appIdentifier, forKey: .appIdentifier)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(deviceType, forKey: .deviceType)
        try container.encode(timeZone, forKey: .timeZone)
        try container.encode(localeIdentifier, forKey: .localeIdentifier)
        try container.encode(deviceToken, forKey: .deviceToken)
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case appIdentifier = "appIdentifier"
        case appVersion = "appVersion"
        case deviceType = "deviceType"
        case timeZone = "timeZone"
        case localeIdentifier = "localeIdentifier"
        case deviceToken = "deviceToken"
    }
}
