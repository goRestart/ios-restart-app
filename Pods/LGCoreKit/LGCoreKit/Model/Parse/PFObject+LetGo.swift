//
//  PFObject+LetGo.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

extension PFObject {
    public var isSaved: Bool {
        return objectId != nil
    }
}
