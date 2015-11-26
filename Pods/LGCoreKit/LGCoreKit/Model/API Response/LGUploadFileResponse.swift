//
//  LGUploadFileResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 28/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGUploadFileResponse {
    
    public let imageId: String
    
}

// MARK: - ResponseObjectSerializable
extension LGUploadFileResponse : ResponseObjectSerializable {

    /**
    Representation will come in the following json form:
    
        {
            "imageId": "    -dd60-42ea-8284-35db009474f3"
        }
    */
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        //Direct parsing
        guard let theImageId : String = JSON.parse(representation) <| "imageId" else {
            return nil
        }
        self.imageId = theImageId
    }
}