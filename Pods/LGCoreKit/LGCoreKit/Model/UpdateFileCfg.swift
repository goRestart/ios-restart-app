//
//  UpdateFileCfg.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Alamofire
import SwiftyJSON

@objc public class UpdateFileCfg: ResponseObjectSerializable {
   
    // Constant
    public static let currentVersionInfoJSONKey = "currentVersionInfo"
    private static let buildNumberJSONKey = "buildNumber"
    private static let forceUpdateVersionsJSONKey = "forceUpdateVersions"
    private static let configURLJSONKey = "configURL"

    public var buildNumber : NSNumber
    public var forceUpdateVersions : NSMutableArray
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
        
        var currentVersionInfo = json[UpdateFileCfg.currentVersionInfoJSONKey]
        
        buildNumber = currentVersionInfo[UpdateFileCfg.buildNumberJSONKey].intValue
        
        if let conflictVersions = currentVersionInfo[UpdateFileCfg.forceUpdateVersionsJSONKey].array {
            for versionJson in conflictVersions {
                forceUpdateVersions.addObject(NSNumber(int: versionJson.int32Value))
            }
        }
        
        if let cfgURL = json[UpdateFileCfg.configURLJSONKey].string {
            configURL = cfgURL
        }
    }

    // MARK : - Public Methods

    public func jsonRepresentation() -> JSON? {
        
        var tmpFinalDic : [String:AnyObject] = [:]
        var tmpCurrentVersionDic : [String:AnyObject] = [:]
        
        tmpCurrentVersionDic[UpdateFileCfg.buildNumberJSONKey] = buildNumber
        tmpCurrentVersionDic[UpdateFileCfg.forceUpdateVersionsJSONKey] = forceUpdateVersions
        
        tmpFinalDic[UpdateFileCfg.currentVersionInfoJSONKey] = tmpCurrentVersionDic
        tmpFinalDic[UpdateFileCfg.configURLJSONKey] = configURL
        
        var json = JSON(tmpFinalDic)
        
        return json
    }
}
