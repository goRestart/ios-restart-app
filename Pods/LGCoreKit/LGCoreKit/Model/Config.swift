//
//  Config.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Alamofire
import SwiftyJSON

public class Config: ResponseObjectSerializable {
   
    // Constant
    public static let currentVersionInfoJSONKey = "currentVersionInfo"
    private static let buildNumberJSONKey = "buildNumber"
    private static let forceUpdateVersionsJSONKey = "forceUpdateVersions"
    private static let configURLJSONKey = "configURL"

    public var buildNumber : Int
    public var forceUpdateVersions : [Int]
    public var configURL : String
    
    // MARK : - Lifecycle
    
    public init() {
        buildNumber = 0
        forceUpdateVersions = []
        configURL = ""
    }
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {

        let json = JSON(representation)
        self.init(json: json)
    }
    
    public required convenience init?(json: JSON) {
        self.init()
        
        var currentVersionInfo = json[Config.currentVersionInfoJSONKey]
        
        buildNumber = currentVersionInfo[Config.buildNumberJSONKey].intValue
        
        if let forceUpdateVersionsJSON = currentVersionInfo[Config.forceUpdateVersionsJSONKey].array {
            for forceUpdateVersionJSON in forceUpdateVersionsJSON {
                forceUpdateVersions.append(forceUpdateVersionJSON.intValue)
            }
        }
        
        if let cfgURL = json[Config.configURLJSONKey].string {
            configURL = cfgURL
        }
    }

    // MARK : - Public Methods

    public func jsonRepresentation() -> JSON {
        
        var tmpFinalDic : [String:AnyObject] = [:]
        var tmpCurrentVersionDic : [String:AnyObject] = [:]
        
        tmpCurrentVersionDic[Config.buildNumberJSONKey] = buildNumber
        tmpCurrentVersionDic[Config.forceUpdateVersionsJSONKey] = forceUpdateVersions
        
        tmpFinalDic[Config.currentVersionInfoJSONKey] = tmpCurrentVersionDic
        tmpFinalDic[Config.configURLJSONKey] = configURL
        
        return JSON(tmpFinalDic)
    }
}
