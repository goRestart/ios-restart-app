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
    private static let userRatingJSONKey = "userRating"
    private static let myMessagesCountJSONKey = "myMessagesCountForRating"
    private static let otherMessagesCountJSONKey = "otherMessagesCountForRating"

    private(set) var buildNumber : Int
    private(set) var forceUpdateVersions : [Int]
    private(set) var configURL : String
    private(set) var quadKeyZoomLevel: Int
    private(set) var myMessagesCountForRating: Int    // # of messages I must have sent to be able to rate an user
    private(set) var otherMessagesCountForRating: Int // # of messages another user must have sent to me to be able to rate him


    // MARK : - Lifecycle

    convenience init() {
        self.init(buildNumber: 0, forceUpdateVersions: [], configURL: "",
                  quadKeyZoomLevel: Constants.defaultQuadKeyZoomLevel,
                  myMessagesCountForRating: Constants.myMessagesCountForRating,
                  otherMessagesCountForRating: Constants.otherMessagesCountForRating)
    }

    init(buildNumber : Int, forceUpdateVersions : [Int], configURL : String, quadKeyZoomLevel: Int,
                myMessagesCountForRating: Int, otherMessagesCountForRating: Int) {
        self.buildNumber = buildNumber
        self.forceUpdateVersions = forceUpdateVersions
        self.configURL = configURL
        self.quadKeyZoomLevel = quadKeyZoomLevel
        self.myMessagesCountForRating = myMessagesCountForRating
        self.otherMessagesCountForRating = otherMessagesCountForRating
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

        if let userRating: JSON = json.decode(Config.userRatingJSONKey) {
            if let myMessages: Int = userRating.decode(Config.myMessagesCountJSONKey) {
                self.myMessagesCountForRating = myMessages
            }
            if let otherMessages: Int = userRating.decode(Config.otherMessagesCountJSONKey) {
                self.otherMessagesCountForRating = otherMessages
            }
        }
    }

    // MARK : - Public Methods

    func jsonRepresentation() -> Any {

        var tmpFinalDic : [String:Any] = [:]
        var tmpCurrentVersionDic : [String:Any] = [:]
        var tmpUserRatingDic : [String:Any] = [:]

        tmpCurrentVersionDic[Config.buildNumberJSONKey] = buildNumber
        tmpCurrentVersionDic[Config.forceUpdateVersionsJSONKey] = forceUpdateVersions

        tmpFinalDic[Config.currentVersionInfoJSONKey] = tmpCurrentVersionDic
        tmpFinalDic[Config.configURLJSONKey] = configURL
        tmpFinalDic[Config.quadKeyZoomLevelJSONKey] = quadKeyZoomLevel

        tmpUserRatingDic[Config.myMessagesCountJSONKey] = myMessagesCountForRating
        tmpUserRatingDic[Config.otherMessagesCountJSONKey] = otherMessagesCountForRating

        tmpFinalDic[Config.userRatingJSONKey] = tmpUserRatingDic

        return tmpFinalDic
    }
}
