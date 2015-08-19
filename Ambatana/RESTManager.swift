//
//  RESTManager.swift
//  LetGo
//
//  Created by Nacho on 13/4/15.
//  Copyright (c) 2015 LetGo. All rights reserved.
//

import Alamofire
import CoreLocation
import LGCoreKit
import Parse
import UIKit

// private singleton instance
private let _singletonInstance = RESTManager()

private let kLetGoRestAPIEndpoint                           = "/api"
private let kLetGoRestAPIJSONFormatSuffix                   = ".json"
private let kLetGoRestAPISynchronizeProductURL              = "/sincronizedb"
let kLetGoRestAPISynchronizeProductMaxAttempts              = 3

/** 
 * The class RESTManager is in charge of managing all communications with the REST API of LetGo.
 * RESTManager uses the Singleton design pattern, so it must be instanciated and used through sharedInstance by calling RESTManager.sharedInstance()
 */
class RESTManager: NSObject {
    // data
    var restDispatchQueue: dispatch_queue_t

    // MARK: - LifeCycle
    
    override init() {
        if iOSVersionAtLeast("8.0") {
            let queueAttributes = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0)
            restDispatchQueue = dispatch_queue_create("com.letgo.LetGoRESTManagerQueue", queueAttributes)
        } else { restDispatchQueue = dispatch_queue_create("com.letgo.LetGoRESTManagerQueue", DISPATCH_QUEUE_SERIAL) }
        super.init()
    }
    
    /** Shared instance */
    class var sharedInstance: RESTManager {
        return _singletonInstance
    }

    // MARK: - Update and synchronization of products
    
    /** Synchronizes a product created in Parse to the LetGo backend */
    func synchronizeProductFromParse(parseObjectId: String, attempt: Int, completion: ((success: Bool) -> Void)? ) -> Void {
        // max attempts reached?
        if attempt > kLetGoRestAPISynchronizeProductMaxAttempts { completion?(success: false) }
        
        // build URL request.
        let urlString = EnvironmentProxy.sharedInstance.apiBaseURL + kLetGoRestAPIEndpoint + kLetGoRestAPISynchronizeProductURL + kLetGoRestAPIJSONFormatSuffix
        if let url = NSURL(string: urlString) {
            request(.GET, url, parameters: nil).response({ (request, response, data, error) -> Void in
                if error == nil && (response?.statusCode >= 200 && response?.statusCode < 300) { // success
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion?(success: true)
                    })
                } else { // retry after one minute (up to three times).
                    dispatch_after(dispatchTimeForSeconds(60), self.restDispatchQueue, { () -> Void in
                        self.synchronizeProductFromParse(parseObjectId, attempt: (attempt+1), completion: completion)
                    })
                }
            })
        } else { completion?(success: false) }
    }
}


















