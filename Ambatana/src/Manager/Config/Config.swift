//
//  Config.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Alamofire
import Argo
import LGCoreKit

class Config: ResponseObjectSerializable {

    // Constant
    static let currentVersionInfoJSONKey = "currentVersionInfo"
    private static let buildNumberJSONKey = "buildNumber"
    private static let forceUpdateVersionsJSONKey = "forceUpdateVersions"
    private static let configURLJSONKey = "configURL"
    private static let quadKeyZoomLevelJSONKey = "quadKeyZoomLevel"

    private(set) var buildNumber : Int
    private(set) var forceUpdateVersions : [Int]
    private(set) var configURL : String
    private(set) var quadKeyZoomLevel: Int
    

    // MARK : - Lifecycle

    convenience init() {
        self.init(buildNumber: 0,
                  forceUpdateVersions: [],
                  configURL: "",
                  quadKeyZoomLevel: Constants.defaultQuadKeyZoomLevel)
    }

    init(buildNumber: Int,
         forceUpdateVersions: [Int],
         configURL: String,
         quadKeyZoomLevel: Int) {
        self.buildNumber = buildNumber
        self.forceUpdateVersions = forceUpdateVersions
        self.configURL = configURL
        self.quadKeyZoomLevel = quadKeyZoomLevel
    }

    required convenience init?(response: HTTPURLResponse, representation: Any) {
        let json = JSON(representation)
        self.init(json: json)
    }

    required convenience init?(data: Data) {
        guard let json = JSON.parse(data: data) else {
            return nil
        }
        self.init(json: json)
    }

    required convenience init(json: JSON) {
        self.init()

        if let currentVersionInfo: JSON = json.decode(Config.currentVersionInfoJSONKey) {
            if let buildNumber: Int = currentVersionInfo.decode(Config.buildNumberJSONKey) {
                self.buildNumber = buildNumber
            }
            if let forceUpdateVersions: [Int] = currentVersionInfo.decode(Config.forceUpdateVersionsJSONKey) {
                self.forceUpdateVersions = forceUpdateVersions
            }
        }

        if let cfgURL : String = json.decode(Config.configURLJSONKey) {
            self.configURL = cfgURL
        }

        if let quadKeyZoomLevel: Int = json.decode(Config.quadKeyZoomLevelJSONKey) {
            self.quadKeyZoomLevel = quadKeyZoomLevel
        }
    }

    // MARK : - Public Methods

    func jsonRepresentation() -> Any {
        var tmpFinalDic : [String:Any] = [:]
        var tmpCurrentVersionDic : [String:Any] = [:]

        tmpCurrentVersionDic[Config.buildNumberJSONKey] = buildNumber
        tmpCurrentVersionDic[Config.forceUpdateVersionsJSONKey] = forceUpdateVersions

        tmpFinalDic[Config.currentVersionInfoJSONKey] = tmpCurrentVersionDic
        tmpFinalDic[Config.configURLJSONKey] = configURL
        tmpFinalDic[Config.quadKeyZoomLevelJSONKey] = quadKeyZoomLevel

        return tmpFinalDic
    }
}
