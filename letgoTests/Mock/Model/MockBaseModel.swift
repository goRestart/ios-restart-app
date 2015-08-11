//
//  MockBaseModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

@objc class MockBaseModel: BaseModel {
    var objectId: String!
    var createdAt: NSDate!
    var updatedAt: NSDate!
    
    var isSaved: Bool {
        return objectId != nil
    }
    var acl: AccessControlList?
    
    // MARK: - Lifecycle
    
    init() {
        self.acl = nil
    }
}
