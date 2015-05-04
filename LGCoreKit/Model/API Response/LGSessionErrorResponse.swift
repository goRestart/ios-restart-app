//
//  LGSessionErrorResponse.swift
//  LGCoreKit
//
//  Created by AHL on 29/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

public class LGSessionErrorResponse {
    
    // Constant
    // > JSON keys
    private static let errorJSONKey = "error"
    private static let errorDescriptionJSONKey = "error_description"
    
    // iVars
    public var error: String
    public var errorDescription: String?
    
    // MARK: - Lifecycle
    
    //{
    //    "error": "invalid_client",
    //    "error_description": "The client credentials are invalid"
    //}
    public init?(json: JSON) {
        if let error = json[LGSessionErrorResponse.errorJSONKey].string {
            self.error = error
        }
        else {
            self.error = ""
            return nil
        }
        self.errorDescription = json[LGSessionErrorResponse.errorDescriptionJSONKey].string
    }
}