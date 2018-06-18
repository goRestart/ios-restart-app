import LGComponents

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
    
    init(buildNumber: Int, forceUpdateVersions: [Int], configURL: String, quadKeyZoomLevel: Int) {
        self.buildNumber = buildNumber
        self.forceUpdateVersions = forceUpdateVersions
        self.configURL = configURL
        self.quadKeyZoomLevel = quadKeyZoomLevel
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let currentVersionInfo = try? values.nestedContainer(keyedBy: CurrentVersionInfoKeys.self,
                                                                forKey: .currentVersionInfo) {
            buildNumber = (try currentVersionInfo.decodeIfPresent(Int.self, forKey: .buildNumber)) ?? 0
            forceUpdateVersions = (try currentVersionInfo.decodeIfPresent([Int].self, forKey: .forceUpdateVersions)) ?? []
        } else {
            buildNumber = 0
            forceUpdateVersions = []
        }
        
        configURL = (try values.decodeIfPresent(String.self, forKey: .configURL)) ?? ""
        
        quadKeyZoomLevel = (try values.decodeIfPresent(Int.self, forKey: .quadKeyZoomLevel)) ?? SharedConstants.defaultQuadKeyZoomLevel
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
