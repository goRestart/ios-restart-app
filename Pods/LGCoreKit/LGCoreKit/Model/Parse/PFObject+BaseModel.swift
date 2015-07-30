//
//  PFObject+BaseModel.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

extension PFObject: BaseModel {
    public var isSaved: Bool {
        return objectId != nil
    }
    
    public var acl: AccessControlList? {
        get {
            return ACL
        }
        set {
            if let parseACL = newValue as? PFACL {
                ACL = parseACL
            }
        }
    }
}
