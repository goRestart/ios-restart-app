//
//  Config.swift
//  Pods
//
//  Created by Dídac on 06/08/15.
//
//

import Alamofire
import Argo

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

        let json = JSON.parse(representation)
        self.init(json: json)
    }
    
    public required convenience init?(data: NSData) {
        guard let json = JSON.parse(data: data) else {
            return nil
        }
        self.init(json: json)
    }
    
    public required convenience init?(json: JSON) {
        self.init()
        
        if let currentVersionInfo : JSON = json <| Config.currentVersionInfoJSONKey {
            if let theBuildNumber : Int = currentVersionInfo <| Config.buildNumberJSONKey {
                self.buildNumber = theBuildNumber
            }
            
            if let theForceUpdateVersions : [Int] = currentVersionInfo <|| Config.forceUpdateVersionsJSONKey {
                self.forceUpdateVersions = theForceUpdateVersions
            }
        }
        
        if let cfgURL : String = json <| Config.configURLJSONKey {
            self.configURL = cfgURL
        }
    }

    // MARK : - Public Methods
    
    public func jsonRepresentation() -> AnyObject {
        
        var tmpFinalDic : [String:AnyObject] = [:]
        var tmpCurrentVersionDic : [String:AnyObject] = [:]
        
        tmpCurrentVersionDic[Config.buildNumberJSONKey] = buildNumber
        tmpCurrentVersionDic[Config.forceUpdateVersionsJSONKey] = forceUpdateVersions
        
        tmpFinalDic[Config.currentVersionInfoJSONKey] = tmpCurrentVersionDic
        tmpFinalDic[Config.configURLJSONKey] = configURL
        
        return tmpFinalDic
    }
}
