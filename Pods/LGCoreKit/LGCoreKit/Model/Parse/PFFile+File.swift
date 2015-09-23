//
//  PFFile+File.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

extension PFFile: File {
    public var fileURL: NSURL? {
        if let actualURLStr = url {
            return NSURL(string: actualURLStr)
        }
        return nil
    }
    
    public var token: String? {
        if let actualToken = self.token {
            return actualToken
        }
        return nil
    }
    
    public var isSaved: Bool {
        return url != nil
    }
}
