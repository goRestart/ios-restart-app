//
//  LGConfigDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public class LGConfigDAO : ConfigDAO {
    let fileCachePath : String
    
    // MARK: - Lifecycle
    
    public init(bundle: NSBundle, configFileName: String) {
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as NSString
        fileCachePath = cachePath.stringByAppendingString("/\(configFileName).json")
        
        // If it's not in cache directory, then copy it from bundle
        let fm = NSFileManager.defaultManager()
        
        if !fm.fileExistsAtPath(fileCachePath) {
            let path = bundle.pathForResource(configFileName, ofType: "json")
            
            if let fileBundlePath = path {
                do {
                    try fm.copyItemAtPath(fileBundlePath, toPath: fileCachePath)
                } catch _ {}
            }
        }
    }
    
    // MARK: - Public methods
    
    public func retrieve() -> Config? {

        let fm = NSFileManager.defaultManager()
        
        // Cached in cache directory
        var path: String? = nil
        if fm.fileExistsAtPath(fileCachePath) {
            path = fileCachePath
        }
        
        // If we don't have a path or the data cannot be loaded, then exit
        guard let actualPath = path, let data = NSData(contentsOfFile: actualPath) else {
            return nil
        }

        let json = JSON(data:data)
        return Config(json: json)
    }
    
    public func save(configFile: Config) {

        // create json from cfgFile: UpdateFileCfg
        let json = configFile.jsonRepresentation()
        
        var jsonData: NSData? = nil
        do {
            try jsonData = json.rawData()
        } catch _ {}
        
        guard let actualJSONData = jsonData else {
            return
        }
        
        // save into cache
        let fm = NSFileManager.defaultManager()
        if !fm.fileExistsAtPath(fileCachePath) {
            fm.createFileAtPath(fileCachePath, contents: actualJSONData, attributes: nil)
        }
        else {
            do {
                try fm.removeItemAtPath(fileCachePath)
            } catch _ {}
            fm.createFileAtPath(fileCachePath, contents: actualJSONData, attributes: nil)
        }
    }
}
