//
//  Config.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

struct Config: Codable {
    let buildNumber: Int
    let forceUpdateVersions: [Int]
    let configURL: String
    let quadKeyZoomLevel: Int
    
    enum CodingKeys: String, CodingKey {
        case currentVersionInfo
        case configURL
        case quadKeyZoomLevel
    }
    
    enum CurrentVersionInfoKeys: String, CodingKey {
        case buildNumber
        case forceUpdateVersions
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            let currentVersionInfo = try values.nestedContainer(keyedBy: CurrentVersionInfoKeys.self,
                                                                forKey: .currentVersionInfo)
            buildNumber = (try? currentVersionInfo.decode(Int.self, forKey: .buildNumber)) ?? 0
            forceUpdateVersions = (try? currentVersionInfo.decode([Int].self, forKey: .forceUpdateVersions)) ?? []
        } catch jsonError {
            buildNumber = 0
            forceUpdateVersions = []
        }
        
        configURL = (try? values.decode(String.self, forKey: .configURL)) ?? ""
        
        do {
            quadKeyZoomLevel = try values.decode(Int.self, forKey: .quadKeyZoomLevel)
        } catch {
            quadKeyZoomLevel =  Constants.defaultQuadKeyZoomLevel
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var currentVersionInfo = container.nestedContainer(keyedBy: CurrentVersionInfoKeys.self,
                                                           forKey: .currentVersionInfo)
        try currentVersionInfo.encode(buildNumber, forKey: .buildNumber)
        try currentVersionInfo.encode(forceUpdateVersions, forKey: .forceUpdateVersions)
        
        try container.encode(configURL, forKey: .configURL)
        try container.encode(quadKeyZoomLevel, forKey: .quadKeyZoomLevel)
    }
}
