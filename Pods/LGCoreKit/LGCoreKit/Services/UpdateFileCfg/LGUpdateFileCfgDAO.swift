//
//  LGUpdateFileCfgDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public class LGUpdateFileCfgDAO : UpdateFileCfgDAO {
    
    public private(set) var updateFileCfg : UpdateFileCfg?
    
    public var fileBundlePath : String
    public var fileCachePath : String
    
    // MARK: - Lifecycle
    
    public convenience init() {
        
        self.init(cfgFile: nil)

    }
    
    public init(cfgFile: UpdateFileCfg?) {
        
        let filename = EnvironmentProxy.sharedInstance.updateFileCfgName
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! NSString
        
        var bundle = NSBundle.LGCoreKitBundle()
        
        fileBundlePath = bundle.pathForResource(filename, ofType: "json")!
        fileCachePath = cachePath.stringByAppendingString("/\(filename).json")

        if let actualCfgFile = cfgFile {
            updateFileCfg = cfgFile
        }
    }
    
    // MARK: public methods
    
    public func getUpdateCfgFileFromBundle() -> UpdateFileCfg? {
        
        let fm = NSFileManager.defaultManager()
        
        if fm.fileExistsAtPath(fileCachePath) {
            // get file from fileCachePath
            let data = NSData(contentsOfFile: fileCachePath)!
            let json = JSON(data:data)
            
            updateFileCfg = UpdateFileCfg(json: json)
            
        } else if fm.fileExistsAtPath(fileBundlePath) {
            // get file from fileBundlePath
            fm.copyItemAtPath(fileBundlePath, toPath: fileCachePath, error: nil)
            let data = NSData(contentsOfFile: fileBundlePath)!
            let json = JSON(data:data)
            
            updateFileCfg = UpdateFileCfg(json: json)
            
        } else {
            // there's no file yet, this case SHOULD NEVER HAPPEN
            updateFileCfg = nil
        }
        
        return updateFileCfg
    }
    
    public func saveUpdateCfgFileInBundle(cfgFile: UpdateFileCfg) {
        
        // create json from cfgFile: UpdateFileCfg
        
        var json = cfgFile.jsonRepresentation()
        
        var jsonData = json?.rawData()
        
        let fm = NSFileManager.defaultManager()
        
        if !fm.fileExistsAtPath(fileCachePath) {
            fm.createFileAtPath(fileCachePath, contents: jsonData, attributes: nil)
        } else {
            fm.removeItemAtPath(fileCachePath, error: nil)
            fm.createFileAtPath(fileCachePath, contents: jsonData, attributes: nil)
        }
    }
}
