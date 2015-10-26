//
//  LGUploadFileResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 28/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

public class LGUploadFileResponse : ResponseObjectSerializable {
    
    // Constant
    private static let imageIdKey = "imageId"
    
    public var imageId: String
    
    // MARK: - Lifecycle
    
    public init() {
        imageId = ""
    }
    
    // MARK: - ResponseObjectSerializable
    //    {
    //        "imageId": "9c1d180c-dd60-42ea-8284-35db009474f3"
    //    }
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)
        
        if let actualImageId = json[LGUploadFileResponse.imageIdKey].string {
            imageId = actualImageId
        }
        else {
            return nil
        }
    }
}