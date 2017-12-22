//
//  LGInstallationAPI.swift
//  LGCoreKit
//
//  Created by Raúl de Oñate Blanco on 03/11/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

struct LGInstallationAPI: Installation, Codable {
    var objectId: String?
    var appIdentifier: String
    var appVersion: String
    var deviceType: String
    var timeZone: String?
    var localeIdentifier: String?
    var deviceToken: String?
}

extension LGInstallationAPI {
    
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
    
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case appIdentifier = "app_identifier"
        case appVersion = "app_version"
        case deviceType = "device_type"
        case timeZone = "time_zone"
        case localeIdentifier = "locale_identifier"
        case deviceToken = "device_token"
    }
}
