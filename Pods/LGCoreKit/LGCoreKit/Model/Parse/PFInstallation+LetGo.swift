//
//  PFInstallation+LetGo.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 10/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


import Parse

extension PFInstallation: Installation {
    
    enum FieldKey: String {
        case UserId = "user_objectId", Username = "username"
    }
    
    public var userId: String? {
        get {
            return self[FieldKey.UserId.rawValue] as? String
        }
        set {
            self[FieldKey.UserId.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var username: String? {
        get {
            return self[FieldKey.Username.rawValue] as? String
        }
        set {
            self[FieldKey.Username.rawValue] = newValue ?? NSNull()
        }
    }
}