//
//  MockBaseModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class MockBaseModel: BaseModel {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    var isSaved: Bool {
        return objectId != nil
    }
    
    // MARK: - Lifecycle
    
    init() {
    }
}
